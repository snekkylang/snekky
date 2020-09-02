package compiler;

import error.ErrorHelper;
import object.ObjectOrigin;
import compiler.symbol.SymbolOrigin;
import ast.NodeType;
import error.CompileError;
import sys.io.File;
import object.objects.*;
import compiler.symbol.SymbolTable;
import haxe.io.BytesBuffer;
import code.Code;
import code.OpCode;
import ast.nodes.*;
import ast.nodes.datatypes.*;

class Compiler {

    public final constants:Array<Object> = [];
    public var instructions = new BytesBuffer();
    public final lineNumberTable = new LineNumberTable();
    final symbolTable = new SymbolTable();

    // Position of last break instruction
    var lastBreakPos:Int = -1;

    public function new() { }

    public function writeByteCode() {
        File.saveBytes("program.bite", instructions.getBytes());
    }

    public function compile(node:Node) {
        switch(node.type) {
            case NodeType.Block:
                final cBlock = cast(node, Block);

                symbolTable.newScope();
                for (blockNode in cBlock.body) {
                    compile(blockNode);
                }
                symbolTable.setParent();
            case NodeType.Break:
                lastBreakPos = instructions.length;
                emit(OpCode.Jump, node.position, [0]);
            case NodeType.Statement:
                final cStatement = cast(node, Statement);

                compile(cStatement.value.value);
                emit(OpCode.Pop, cStatement.position, []);
            case NodeType.Expression:
                final cExpression = cast(node, Expression);
                compile(cExpression.value);
            case NodeType.Plus | NodeType.Multiply | NodeType.Equal | NodeType.SmallerThan | 
                NodeType.GreaterThan | NodeType.Minus | NodeType.Divide | NodeType.Modulo:

                final cOperator = cast(node, Operator);
                compile(cOperator.left);
                compile(cOperator.right);

                switch (cOperator.type) {
                    case NodeType.Plus: emit(OpCode.Add, node.position, []);
                    case NodeType.Multiply: emit(OpCode.Multiply, node.position, []);
                    case NodeType.Equal: emit(OpCode.Equals, node.position, []);
                    case NodeType.SmallerThan: emit(OpCode.SmallerThan, node.position, []);
                    case NodeType.GreaterThan: emit(OpCode.GreaterThan, node.position, []);
                    case NodeType.Minus: emit(OpCode.Subtract, node.position, []);
                    case NodeType.Divide: emit(OpCode.Divide, node.position, []);
                    case NodeType.Modulo: emit(OpCode.Modulo, node.position, []);
                    default:
                }
            case NodeType.Negation | NodeType.Inversion:
                final cOperator = cast(node, Operator);
                compile(cOperator.right);
                if (cOperator.type == NodeType.Negation) {
                    emit(OpCode.Negate, node.position, []);
                } else {
                    emit(OpCode.Invert, node.position, []);
                }
            case NodeType.Variable:
                final cVariable = cast(node, Variable);

                if (symbolTable.currentScope.exists(cVariable.name)) {
                    CompileError.redeclareVariable(cVariable.position, cVariable.name);
                }

                final symbol = symbolTable.define(cVariable.name, cVariable.mutable, SymbolOrigin.UserDefined);
                compile(cVariable.value);
                emit(OpCode.SetLocal, cVariable.position, [symbol.index]);
            case NodeType.VariableAssign:
                final cVariableAssign = cast(node, VariableAssign);
                final symbol = symbolTable.resolve(cVariableAssign.name);
                if (symbol == null) {
                    CompileError.symbolUndefined(cVariableAssign.position, cVariableAssign.name);
                }
                if (!symbol.mutable) {
                    CompileError.symbolImmutable(cVariableAssign.position, cVariableAssign.name);
                }
                compile(cVariableAssign.value);
                emit(OpCode.SetLocal, cVariableAssign.position, [symbol.index]);
            case NodeType.Ident:
                final cIdent = cast(node, Ident);
                final symbol = symbolTable.resolve(cIdent.value);
                if (symbol == null) {
                    CompileError.symbolUndefined(cIdent.position, cIdent.value);
                }
                if (symbol.origin == SymbolOrigin.UserDefined) {
                    emit(OpCode.GetLocal, node.position, [symbol.index]);
                } else {
                    emit(OpCode.GetBuiltIn, node.position, [symbol.index]);
                }
            case NodeType.Function:
                final cFunction = cast(node, FunctionN);
                emit(OpCode.Constant, node.position, [constants.length]);

                final jumpInstructionPos = instructions.length;
                emit(OpCode.Jump, node.position, [0]);

                constants.push(new FunctionObj(instructions.length, ObjectOrigin.UserDefined));

                for (parameter in cFunction.parameters) {
                    final symbol = symbolTable.define(parameter.value, false, SymbolOrigin.UserDefined);
                    emit(OpCode.SetLocal, node.position, [symbol.index]);
                }

                compile(cFunction.block);
                emit(OpCode.Return, node.position, []);

                overwriteInstruction(jumpInstructionPos, [instructions.length]);
            case NodeType.FunctionCall:
                final cCall = cast(node, FunctionCall);
                
                var i = cCall.parameters.length;
                while (--i >= 0) {
                    compile(cCall.parameters[i]);
                }

                compile(cCall.target);

                emit(OpCode.Call, node.position, []);
            case NodeType.Return:
                final cReturn = cast(node, Return);

                compile(cReturn.value);

                emit(OpCode.Return, node.position, []);
            case NodeType.If:
                final cIf = cast(node, If);
                compile(cIf.condition);

                final jumpNotInstructionPos = instructions.length;
                emit(OpCode.JumpNot, node.position, [0]);

                compile(cIf.consequence);
                final jumpInstructionPos = instructions.length;
                emit(OpCode.Jump, node.position, [0]);

                final jumpNotPos = instructions.length;
                if (cIf.alternative != null) {
                    compile(cIf.alternative);
                }
                final jumpPos = instructions.length;

                overwriteInstruction(jumpNotInstructionPos, [jumpNotPos]);
                overwriteInstruction(jumpInstructionPos, [jumpPos]);
            case NodeType.While:
                final cWhile = cast(node, While);

                final jumpPos = instructions.length;
                compile(cWhile.condition);

                final jumpNotInstructionPos = instructions.length;
                emit(OpCode.JumpNot, node.position, [0]);
                compile(cWhile.block);
                emit(OpCode.Jump, node.position, [jumpPos]);

                if (lastBreakPos != -1) {
                    overwriteInstruction(lastBreakPos, [instructions.length]);
                    lastBreakPos = -1;
                }

                overwriteInstruction(jumpNotInstructionPos, [instructions.length]);
            case NodeType.Float | NodeType.Boolean | NodeType.String:
                switch (node.type) {
                    case NodeType.Float:
                        constants.push(new FloatObj(cast(node, FloatN).value));
                    case NodeType.Boolean:
                        constants.push(new FloatObj(cast(node, Boolean).value ? 1 : 0));
                    case NodeType.String:
                        constants.push(new StringObj(cast(node, StringN).value));
                    default:
                }

                emit(OpCode.Constant, node.position, [constants.length - 1]);
            default:
        }
    }

    function overwriteInstruction(pos:Int, operands:Array<Int>) {
        final buffer = new BytesBuffer();
        final currentBytes = instructions.getBytes();
        currentBytes.setInt32(pos + 1, operands[0]);
        buffer.add(currentBytes);
        instructions = buffer;
    }

    function emit(op:OpCode, position:Int, operands:Array<Int>) {
        lineNumberTable.define(instructions.length, ErrorHelper.resolvePosition(position));
        final instruction = Code.make(op, operands);
        instructions.add(instruction);
    }
}