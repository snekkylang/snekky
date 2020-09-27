package compiler;

import std.BuiltInTable;
import haxe.io.Bytes;
import compiler.constant.ConstantPool;
import haxe.io.BytesOutput;
import compiler.debug.LocalVariableTable;
import compiler.debug.LineNumberTable;
import error.ErrorHelper;
import ast.NodeType;
import error.CompileError;
import compiler.symbol.SymbolTable;
import code.Code;
import code.OpCode;
import ast.nodes.*;
import ast.nodes.datatypes.*;
import object.Object;

class Compiler {

    final constantPool = new ConstantPool();
    var instructions = new BytesOutput();
    final lineNumberTable = new LineNumberTable();
    final localVariableTable = new LocalVariableTable();
    final symbolTable = new SymbolTable();

    final noDebug:Bool;

    // Positions of break instructions
    var breakPositions:Array<Int> = [];

    public function new(noDebug:Bool) {
        this.noDebug = noDebug;
    }

    public function getByteCode():Bytes {
        final output = new BytesOutput();
        output.write(lineNumberTable.toByteCode());
        output.write(localVariableTable.toByteCode());
        output.write(constantPool.toByteCode());

        final instructionsByteCode = instructions.getBytes();
        output.writeInt32(instructionsByteCode.length);
        output.write(instructionsByteCode);

        return output.getBytes();
    }

    public function compile(node:Node) {
        switch(node.type) {
            case NodeType.Block:
                final cBlock = cast(node, BlockNode);

                symbolTable.newScope();
                for (blockNode in cBlock.body) {
                    compile(blockNode);
                }
                symbolTable.setParent();
            case NodeType.Hash:
                final cHash = cast(node, HashNode);

                var length = 0;

                for (key => value in cHash.values) {
                    compile(key);
                    compile(value);
                    length++;
                }

                emit(OpCode.Hash, node.position, [length]);
            case NodeType.Array:
                final cArray = cast(node, ArrayNode);

                for (value in cArray.values) {
                    compile(value);
                }

                emit(OpCode.Array, node.position, [cArray.values.length]);
            case NodeType.Index:
                final cIndex = cast(node, IndexNode);

                compile(cIndex.target);
                compile(cIndex.index);

                emit(OpCode.LoadIndex, node.position, []);
            case NodeType.IndexAssign:
                final cIndexAssign = cast(node, IndexAssignNode);

                compile(cIndexAssign.index);
                removeLastInstruction();
                compile(cIndexAssign.value);

                emit(OpCode.StoreIndex, node.position, []);
            case NodeType.Break:
                breakPositions.push(instructions.length);
                emit(OpCode.Jump, node.position, [0]);
            case NodeType.Statement:
                final cStatement = cast(node, StatementNode);

                compile(cStatement.value.value);
                emit(OpCode.Pop, cStatement.position, []);
            case NodeType.Expression:
                final cExpression = cast(node, ExpressionNode);
                compile(cExpression.value);
            case NodeType.LogicOr:
                final cOperator = cast(node, OperatorNode);

                compile(cOperator.left);
                emit(OpCode.Not, node.position, []);
                final jumpNotPeekInstructionPos = instructions.length;
                emit(OpCode.JumpNotPeek, node.position, [0]);
                emit(OpCode.Pop, node.position, []);
                compile(cOperator.right);
                final jumpInstructionPos = instructions.length;
                emit(OpCode.Jump, node.position, [0]);
                overwriteInstruction(jumpNotPeekInstructionPos, [instructions.length]);
                emit(OpCode.Not, node.position, []);
                overwriteInstruction(jumpInstructionPos, [instructions.length]);
            case NodeType.LogicAnd:
                final cOperator = cast(node, OperatorNode);

                compile(cOperator.left);
                final jumpNotPeekInstructionPos = instructions.length;
                emit(OpCode.JumpNotPeek, node.position, [0]);
                emit(OpCode.Pop, node.position, []);
                compile(cOperator.right);
                overwriteInstruction(jumpNotPeekInstructionPos, [instructions.length]);
            case NodeType.Plus | NodeType.Multiply | NodeType.Equal | NodeType.SmallerThan | 
                NodeType.GreaterThan | NodeType.Minus | NodeType.Divide | NodeType.Modulo | NodeType.StringConc | NodeType.NotEqual:

                final cOperator = cast(node, OperatorNode);
                compile(cOperator.left);
                compile(cOperator.right);

                switch (cOperator.type) {
                    case NodeType.Plus: emit(OpCode.Add, node.position, []);
                    case NodeType.Multiply: emit(OpCode.Multiply, node.position, []);
                    case NodeType.Equal: emit(OpCode.Equals, node.position, []);
                    case NodeType.SmallerThan: emit(OpCode.LessThan, node.position, []);
                    case NodeType.GreaterThan: emit(OpCode.GreaterThan, node.position, []);
                    case NodeType.Minus: emit(OpCode.Subtract, node.position, []);
                    case NodeType.Divide: emit(OpCode.Divide, node.position, []);
                    case NodeType.Modulo: emit(OpCode.Modulo, node.position, []);
                    case NodeType.StringConc: emit(OpCode.ConcatString, node.position, []);
                    case NodeType.NotEqual:
                        emit(OpCode.Equals, node.position, []);
                        emit(OpCode.Not, node.position, []);
                    default:
                }
            case NodeType.Negation | NodeType.Inversion:
                final cOperator = cast(node, OperatorNode);
                compile(cOperator.right);
                if (cOperator.type == NodeType.Negation) {
                    emit(OpCode.Negate, node.position, []);
                } else {
                    emit(OpCode.Not, node.position, []);
                }
            case NodeType.Variable:
                final cVariable = cast(node, VariableNode);

                if (symbolTable.currentScope.exists(cVariable.name)) {
                    CompileError.redeclareVariable(cVariable.position, cVariable.name);
                }

                if (!noDebug) {
                    localVariableTable.define(instructions.length, cVariable.name);
                }
                final symbol = symbolTable.define(cVariable.name, cVariable.mutable);
                compile(cVariable.value);
                emit(OpCode.Store, cVariable.position, [symbol.index]);
            case NodeType.VariableAssign:
                final cVariableAssign = cast(node, VariableAssignNode);

                final symbol = symbolTable.resolve(cVariableAssign.name);
                if (symbol == null) {
                    CompileError.symbolUndefined(cVariableAssign.position, cVariableAssign.name);
                } else if (!symbol.mutable) {
                    CompileError.symbolImmutable(cVariableAssign.position, cVariableAssign.name);
                }
                
                if (!noDebug) {
                    localVariableTable.define(instructions.length, cVariableAssign.name);
                }
                compile(cVariableAssign.value);
                emit(OpCode.Store, cVariableAssign.position, [symbol.index]);
            case NodeType.Ident:
                final cIdent = cast(node, IdentNode);
                final symbol = symbolTable.resolve(cIdent.value);
                if (symbol == null) {
                    final builtInIndex = BuiltInTable.resolveName(cIdent.value);
                    if (builtInIndex != -1) {
                        emit(OpCode.LoadBuiltIn, node.position, [builtInIndex]);
                    } else {
                        CompileError.symbolUndefined(cIdent.position, cIdent.value);
                    }
                } else {
                    emit(OpCode.Load, node.position, [symbol.index]);     
                }
            case NodeType.Function:
                final cFunction = cast(node, FunctionNode);
                emit(OpCode.Constant, node.position, [constantPool.getSize()]);

                final jumpInstructionPos = instructions.length;
                emit(OpCode.Jump, node.position, [0]);

                constantPool.addConstant(Object.UserFunction(instructions.length));

                symbolTable.newScope();
                for (parameter in cFunction.parameters) {
                    final symbol = symbolTable.define(parameter.value, false);
                    emit(OpCode.Store, node.position, [symbol.index]);
                }

                compile(cFunction.block);
                emit(OpCode.Return, node.position, []);

                overwriteInstruction(jumpInstructionPos, [instructions.length]);

                symbolTable.setParent();
            case NodeType.FunctionCall:
                final cCall = cast(node, CallNode);
                
                var i = cCall.parameters.length;
                while (--i >= 0) {
                    compile(cCall.parameters[i]);
                }

                compile(cCall.target);

                emit(OpCode.Call, node.position, []);
            case NodeType.Return:
                final cReturn = cast(node, ReturnNode);

                if (cReturn.value != null) {
                    compile(cReturn.value);
                }
                
                emit(OpCode.Return, node.position, []);
            case NodeType.If:
                final cIf = cast(node, IfNode);
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
                final cWhile = cast(node, WhileNode);

                final jumpPos = instructions.length;
                compile(cWhile.condition);

                final jumpNotInstructionPos = instructions.length;
                emit(OpCode.JumpNot, node.position, [0]);
                compile(cWhile.block);
                emit(OpCode.Jump, node.position, [jumpPos]);

                for (pos in breakPositions) {
                    overwriteInstruction(pos, [instructions.length]);
                }

                overwriteInstruction(jumpNotInstructionPos, [instructions.length]);
            case NodeType.Float | NodeType.Boolean | NodeType.String | NodeType.Null:
                switch (node.type) {
                    case NodeType.Float:
                        constantPool.addConstant(Object.Float(cast(node, FloatNode).value));
                    case NodeType.Boolean:
                        constantPool.addConstant(Object.Float(cast(node, BooleanNode).value ? 1 : 0));
                    case NodeType.String:
                        constantPool.addConstant(Object.String(cast(node, StringNode).value));
                    case NodeType.Null:
                        constantPool.addConstant(Object.Null);
                    default:
                }

                emit(OpCode.Constant, node.position, [constantPool.getSize() - 1]);
            default:
        }
    }

    function removeLastInstruction() {
        final currentBytes = instructions.getBytes();
        instructions = new BytesOutput();
        instructions.writeBytes(currentBytes, 0, currentBytes.length - 1);
    }

    function overwriteInstruction(pos:Int, operands:Array<Int>) {
        final currentBytes = instructions.getBytes();
        currentBytes.setInt32(pos + 1, operands[0]);
        instructions = new BytesOutput();
        instructions.write(currentBytes);
    }

    function emit(op:Int, position:Int, operands:Array<Int>) {
        if (!noDebug) {
            lineNumberTable.define(instructions.length, ErrorHelper.resolvePosition(position));
        }
        final instruction = Code.make(op, operands);
        
        instructions.write(instruction);
    }
}