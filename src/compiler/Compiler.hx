package compiler;

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
    public final symbolTable = new SymbolTable();

    // Position of last break instruction
    var lastBreakPos:Int = -1;

    public function new() {

    }

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
                emit(OpCode.Jump, [0]);
            case NodeType.Statement:
                final cStatement = cast(node, Statement);
                compile(cStatement.value.value);
                emit(OpCode.Pop, []);
            case NodeType.Expression:
                final cExpression = cast(node, Expression);
                compile(cExpression.value);
            case NodeType.Plus | NodeType.Multiply | NodeType.Equal | NodeType.SmallerThan | 
                NodeType.GreaterThan | NodeType.Minus | NodeType.Divide | NodeType.Modulo:

                final cOperator = cast(node, Operator);
                compile(cOperator.left);
                compile(cOperator.right);

                switch (cOperator.type) {
                    case NodeType.Plus: emit(OpCode.Add, []);
                    case NodeType.Multiply: emit(OpCode.Multiply, []);
                    case NodeType.Equal: emit(OpCode.Equals, []);
                    case NodeType.SmallerThan: emit(OpCode.SmallerThan, []);
                    case NodeType.GreaterThan: emit(OpCode.GreaterThan, []);
                    case NodeType.Minus: emit(OpCode.Subtract, []);
                    case NodeType.Divide: emit(OpCode.Divide, []);
                    case NodeType.Modulo: emit(OpCode.Modulo, []);
                    default:
                }
            case NodeType.Negation | NodeType.Inversion:
                final cOperator = cast(node, Operator);
                compile(cOperator.right);
                if (cOperator.type == NodeType.Negation) {
                    emit(OpCode.Negate, []);
                } else {
                    emit(OpCode.Invert, []);
                }
            case NodeType.Variable:
                final cVariable = cast(node, Variable);

                if (symbolTable.currentScope.exists(cVariable.name)) {
                    CompileError.redeclareVariable(cVariable.position, cVariable.name);
                }

                final symbol = symbolTable.define(cVariable.name, cVariable.position, cVariable.mutable);
                compile(cVariable.value);
                emit(OpCode.SetLocal, [symbol.index]);
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
                emit(OpCode.SetLocal, [symbol.index]);
            case NodeType.Ident:
                final cIdent = cast(node, Ident);
                final symbol = symbolTable.resolve(cIdent.value);
                if (symbol == null) {
                    CompileError.symbolUndefined(cIdent.position, cIdent.value);
                }
                emit(OpCode.GetLocal, [symbol.index]);
            case NodeType.Function:
                final cFunction = cast(node, FunctionN);
                final constantIndex = constants.push(new FunctionObj(0)) - 1;
                emit(OpCode.Constant, [constants.length - 1]);

                final jumpInstructionPos = instructions.length;
                emit(OpCode.Jump, [0]);

                constants[constantIndex] = new FunctionObj(instructions.length);

                for (parameter in cFunction.parameters) {
                    final symbol = symbolTable.define(parameter.value, parameter.position, false);
                    emit(OpCode.SetLocal, [symbol.index]);
                }

                compile(cFunction.block);
                emit(OpCode.Return, []);

                overwriteInstruction(jumpInstructionPos, [instructions.length]);
            case NodeType.FunctionCall:
                final cCall = cast(node, FunctionCall);
                
                var i = cCall.parameters.length;
                while (--i >= 0) {
                    compile(cCall.parameters[i]);
                }

                compile(cCall.target);

                emit(OpCode.Call, []);
            case NodeType.Return:
                final cReturn = cast(node, Return);

                compile(cReturn.value);

                emit(OpCode.Return, []);
            case NodeType.If:
                final cIf = cast(node, If);
                compile(cIf.condition);

                final jumpNotInstructionPos = instructions.length;
                emit(OpCode.JumpNot, [0]);

                compile(cIf.consequence);
                final jumpInstructionPos = instructions.length;
                emit(OpCode.Jump, [0]);

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
                emit(OpCode.JumpNot, [0]);
                compile(cWhile.block);
                emit(OpCode.Jump, [jumpPos]);

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

                emit(OpCode.Constant, [constants.length - 1]);
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

    function emit(op:OpCode, operands:Array<Int>) {
        final instruction = Code.make(op, operands);
        instructions.add(instruction);
    }
}