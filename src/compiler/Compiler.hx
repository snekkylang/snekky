package compiler;

import compiler.symbol.Symbol;
import object.NullObj;
import object.StringObj;
import object.NumberObj;
import object.UserFunctionObj;
import haxe.zip.Compress;
import compiler.debug.FilenameTable;
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

class Compiler {

    final constantPool = new ConstantPool();
    var instructions = new BytesOutput();
    final lineNumberTable = new LineNumberTable();
    final localVariableTable = new LocalVariableTable();
    final symbolTable = new SymbolTable();
    final filenameTable = new FilenameTable();
    var error:CompileError = new CompileError("", "");

    final debug:Bool;

    // Positions of break instructions
    var breakPositions:Array<Int> = [];

    public function new(debug:Bool) {
        this.debug = debug;
    }

    public function getByteCode(compress:Bool):Bytes {
        final program = new BytesOutput();
        program.write(filenameTable.toByteCode());
        program.write(lineNumberTable.toByteCode());
        program.write(localVariableTable.toByteCode());
        program.write(constantPool.toByteCode());

        final instructionsByteCode = instructions.getBytes();
        program.writeInt32(instructionsByteCode.length);
        program.write(instructionsByteCode);

        final output = new BytesOutput();
        output.writeByte(compress ? 1 : 0);
        if (compress) {
            output.write(Compress.run(program.getBytes(), 9));
        } else {
            output.write(program.getBytes());
        }

        return output.getBytes();
    }

    public function compile(node:Node) {
        switch(node.type) {
            case NodeType.File:
                final cFile = cast(node, FileNode);

                final pFilename = error.filename;
                final pCode = error.code;

                error.filename = cFile.filename;
                error.code = cFile.code;

                final startIndex = instructions.length;

                for (blockNode in cFile.body) {
                    compile(blockNode);
                }

                error.filename = pFilename;
                error.code = pCode;

                if (debug) {
                    filenameTable.define(startIndex, instructions.length, cFile.filename);
                }
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
            case NodeType.Range:
                final cRange = cast(node, RangeNode);

                compile(cRange.end);
                compile(cRange.start);
                emit(OpCode.LoadBuiltIn, node.position, [BuiltInTable.resolveName("Range")]);
                if (cRange.inclusive) {
                    constantPool.addConstant(new StringObj("Inclusive", null));
                } else {
                    constantPool.addConstant(new StringObj("Exclusive", null));
                }
                emit(OpCode.Constant, node.position, [constantPool.getSize() - 1]);
                emit(OpCode.LoadIndex, node.position, []);
                emit(OpCode.Call, node.position, [2]);
            case NodeType.Regex:
                final cRegex = cast(node, RegexNode);

                compile(cRegex.flags);
                compile(cRegex.pattern);
                emit(OpCode.LoadBuiltIn, node.position, [BuiltInTable.resolveName("Regex")]);
                constantPool.addConstant(new StringObj("compile", null));
                emit(OpCode.Constant, node.position, [constantPool.getSize() - 1]);
                emit(OpCode.LoadIndex, node.position, []);
                emit(OpCode.Call, node.position, [2]);
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
            case NodeType.Or:
                final cOperator = cast(node, OperatorNode);

                compile(cOperator.left);
                final jumpPeekInstructionPos = instructions.length;
                emit(OpCode.JumpPeek, node.position, [0]);
                emit(OpCode.Pop, node.position, []);
                compile(cOperator.right);
                overwriteInstruction(jumpPeekInstructionPos, [instructions.length]);
            case NodeType.And:
                final cOperator = cast(node, OperatorNode);

                compile(cOperator.left);
                emit(OpCode.Not, node.position, []);
                final jumpPeekInstructionPos = instructions.length;
                emit(OpCode.JumpPeek, node.position, [0]);
                emit(OpCode.Pop, node.position, []);
                compile(cOperator.right);
                final jumpInstructionPos = instructions.length;
                emit(OpCode.Jump, node.position, [0]);
                overwriteInstruction(jumpPeekInstructionPos, [instructions.length]);
                emit(OpCode.Not, node.position, []);
                overwriteInstruction(jumpInstructionPos, [instructions.length]);
            case NodeType.LessThanOrEqual | NodeType.GreaterThanOrEqual:
                final cOperator = cast(node, OperatorNode);

                compile(cOperator.left);
                compile(cOperator.right);
                if (node.type == NodeType.LessThanOrEqual) {
                    emit(OpCode.LessThan, node.position, []);
                } else {
                    emit(OpCode.GreaterThan, node.position, []);
                }
                final jumpPeekInstructionPos = instructions.length;
                emit(OpCode.JumpPeek, node.position, [0]);
                emit(OpCode.Pop, node.position, []);
                compile(cOperator.left);
                compile(cOperator.right);
                emit(OpCode.Equals, node.position, []);
                overwriteInstruction(jumpPeekInstructionPos, [instructions.length]);
            case NodeType.Add | NodeType.Multiply | NodeType.Equals | NodeType.LessThan | 
                NodeType.GreaterThan | NodeType.Subtract | NodeType.Divide | NodeType.Modulo | NodeType.ConcatString | NodeType.NotEquals:

                final cOperator = cast(node, OperatorNode);
                compile(cOperator.left);
                compile(cOperator.right);

                switch (cOperator.type) {
                    case NodeType.Add: emit(OpCode.Add, node.position, []);
                    case NodeType.Multiply: emit(OpCode.Multiply, node.position, []);
                    case NodeType.Equals: emit(OpCode.Equals, node.position, []);
                    case NodeType.LessThan: emit(OpCode.LessThan, node.position, []);
                    case NodeType.GreaterThan: emit(OpCode.GreaterThan, node.position, []);
                    case NodeType.Subtract: emit(OpCode.Subtract, node.position, []);
                    case NodeType.Divide: emit(OpCode.Divide, node.position, []);
                    case NodeType.Modulo: emit(OpCode.Modulo, node.position, []);
                    case NodeType.ConcatString: emit(OpCode.ConcatString, node.position, []);
                    case NodeType.NotEquals:
                        emit(OpCode.Equals, node.position, []);
                        emit(OpCode.Not, node.position, []);
                    default:
                }
            case NodeType.Negate | NodeType.Not:
                final cOperator = cast(node, OperatorNode);
                compile(cOperator.right);
                if (cOperator.type == NodeType.Negate) {
                    emit(OpCode.Negate, node.position, []);
                } else {
                    emit(OpCode.Not, node.position, []);
                }
            case NodeType.Variable:
                final cVariable = cast(node, VariableNode);

                inline function declareVariable(name:String, mutable:Bool):Symbol {
                    if (symbolTable.currentScope.exists(name)) {
                        error.redeclareVariable(cVariable.position, name);
                    }
                    if (debug) {
                        localVariableTable.define(instructions.length, name);
                    }
                    return symbolTable.define(name, mutable);
                }
        
                if (cVariable.name.type == NodeType.Ident) {
                    final cVariableName = cast(cVariable.name, IdentNode).value;

                    final symbol = declareVariable(cVariableName, cVariable.mutable);
                    if (cVariable.value != null) {
                        compile(cVariable.value);
                    }
    
                    emit(OpCode.Store, cVariable.position, [symbol.index]);
                } else if (cVariable.name.type == NodeType.DestructureArray) {
                    final cVariableName = cast(cVariable.name, DestructureArrayNode);

                    for (i => varName in cVariableName.names) {
                        final symbol = declareVariable(varName, cVariable.mutable);
                        if (cVariable.value != null) {
                            compile(cVariable.value);
                        }        

                        emit(OpCode.DestructureArray, node.position, [i]);                        
                        emit(OpCode.Store, cVariable.position, [symbol.index]);  
                    }

                    emit(OpCode.Pop, node.position, []);
                } else {
                    final cVariableName = cast(cVariable.name, DestructureHashNode);

                    for (varName in cVariableName.names) {
                        final symbol = declareVariable(varName, cVariable.mutable);
                        if (cVariable.value != null) {
                            compile(cVariable.value);
                        }        

                        constantPool.addConstant(new StringObj(varName, null));
                        emit(OpCode.Constant, node.position, [constantPool.getSize() - 1]);
                        emit(OpCode.DestructureHash, node.position, []);                        
                        emit(OpCode.Store, cVariable.position, [symbol.index]);  
                    }

                    emit(OpCode.Pop, node.position, []);  
                }
            case NodeType.VariableAssign:
                final cVariableAssign = cast(node, VariableAssignNode);

                final symbol = symbolTable.resolve(cVariableAssign.name.value);
                if (symbol == null) {
                    error.symbolUndefined(cVariableAssign.position, cVariableAssign.name.value);
                } else if (!symbol.mutable) {
                    error.symbolImmutable(cVariableAssign.position, cVariableAssign.name.value);
                }
                
                if (debug) {
                    localVariableTable.define(instructions.length, cVariableAssign.name.value);
                }
                compile(cVariableAssign.value);
                emit(OpCode.Store, cVariableAssign.position, [symbol.index]);
            case NodeType.VariableAssignOp:
                final cVariableAssignOp = cast(node, VariableAssignOpNode);

                final symbol = symbolTable.resolve(cVariableAssignOp.name.value);
                if (symbol == null) {
                    error.symbolUndefined(cVariableAssignOp.position, cVariableAssignOp.name.value);
                } else if (!symbol.mutable) {
                    error.symbolImmutable(cVariableAssignOp.position, cVariableAssignOp.name.value);
                }
                
                if (debug) {
                    localVariableTable.define(instructions.length, cVariableAssignOp.name.value);
                }
                compile(cVariableAssignOp.value);
                emit(OpCode.Store, cVariableAssignOp.position, [symbol.index]);
            case NodeType.Ident:
                final cIdent = cast(node, IdentNode);
                final symbol = symbolTable.resolve(cIdent.value);
                if (symbol == null) {
                    final builtInIndex = BuiltInTable.resolveName(cIdent.value);
                    if (builtInIndex != -1) {
                        emit(OpCode.LoadBuiltIn, node.position, [builtInIndex]);
                    } else {
                        error.symbolUndefined(cIdent.position, cIdent.value);
                    }
                } else {
                    emit(OpCode.Load, node.position, [symbol.index]);     
                }
            case NodeType.Function:
                final cFunction = cast(node, FunctionNode);
                emit(OpCode.Constant, node.position, [constantPool.getSize()]);

                final jumpInstructionPos = instructions.length;
                emit(OpCode.Jump, node.position, [0]);

                constantPool.addConstant(new UserFunctionObj(instructions.length, cFunction.parameters.length, null));

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

                emit(OpCode.Call, node.position, [cCall.parameters.length]);
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
            case NodeType.For:
                final cFor = cast(node, ForNode);

                compile(cFor.iterator);
                constantPool.addConstant(new StringObj("Iterator", null));
                emit(OpCode.Constant, node.position, [constantPool.getSize() - 1]);
                emit(OpCode.LoadIndex, node.position, []);
                emit(OpCode.Call, node.position, [0]);
                final iterator = symbolTable.defineInternal();
                emit(OpCode.Store, node.position, [iterator]);

                final jumpPos = instructions.length;
                emit(OpCode.Load, node.position, [iterator]);
                constantPool.addConstant(new StringObj("hasNext", null));
                emit(OpCode.Constant, node.position, [constantPool.getSize() - 1]);
                emit(OpCode.LoadIndex, node.position, []);
                emit(OpCode.Call, node.position, [0]);
                final jumpNotPos = instructions.length;
                emit(OpCode.JumpNot, node.position, [0]);
                emit(OpCode.Load, node.position, [iterator]);
                constantPool.addConstant(new StringObj("next", null));
                emit(OpCode.Constant, node.position, [constantPool.getSize() - 1]);
                emit(OpCode.LoadIndex, node.position, []);
                emit(OpCode.Call, node.position, [0]);
                symbolTable.newScope();
                if (cFor.variable != null) {
                    compile(cFor.variable);
                } else {
                    emit(OpCode.Pop, node.position, []);
                }
                compile(cFor.block);
                symbolTable.setParent();
                emit(OpCode.Jump, node.position, [jumpPos]);

                for (pos in breakPositions) {
                    overwriteInstruction(pos, [instructions.length]);
                }

                overwriteInstruction(jumpNotPos, [instructions.length]);
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
                        constantPool.addConstant(new NumberObj(cast(node, FloatNode).value, null));
                    case NodeType.Boolean:
                        constantPool.addConstant(new NumberObj(cast(node, BooleanNode).value ? 1 : 0, null));
                    case NodeType.String:
                        constantPool.addConstant(new StringObj(cast(node, StringNode).value, null));
                    case NodeType.Null:
                        constantPool.addConstant(new NullObj(null));
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
        if (debug) {
            lineNumberTable.define(instructions.length, ErrorHelper.resolvePosition(error.code, position));
        }
        final instruction = Code.make(op, operands);
        
        instructions.write(instruction);
    }
}