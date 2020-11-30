package compiler;

import haxe.ds.GenericStack;
import object.BooleanObj;
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
import compiler.debug.VariableTable;
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
    final variableTable = new VariableTable();
    final symbolTable = new SymbolTable();
    final filenameTable = new FilenameTable();
    var error:CompileError = new CompileError("", "");

    final debug:Bool;

    final breakPositions:GenericStack<Int> = new GenericStack();
    final loopPositions:GenericStack<Int> = new GenericStack();
    var functionDepth = 0;

    public function new(debug:Bool) {
        this.debug = debug;
    }

    public function getByteCode(compress:Bool):Bytes {
        final program = new BytesOutput();
        program.write(filenameTable.toByteCode());
        program.write(lineNumberTable.toByteCode());
        program.write(variableTable.toByteCode());
        program.write(constantPool.toByteCode());

        final instructionsByteCode = instructions.getBytes();
        instructions = new BytesOutput();
        instructions.write(instructionsByteCode);
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
                final constantIndex = if (cRange.inclusive) {
                    constantPool.addConstant(new StringObj("Inclusive", null));
                } else {
                    constantPool.addConstant(new StringObj("Exclusive", null));
                }
                emit(OpCode.Constant, node.position, [constantIndex]);
                emit(OpCode.LoadIndex, node.position, []);
                emit(OpCode.Call, node.position, [2]);
            case NodeType.Regex:
                final cRegex = cast(node, RegexNode);

                compile(cRegex.flags);
                compile(cRegex.pattern);
                emit(OpCode.LoadBuiltIn, node.position, [BuiltInTable.resolveName("Regex")]);
                emit(OpCode.Constant, node.position, [constantPool.addConstant(new StringObj("compile", null))]);
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
                if (loopPositions.isEmpty()) {
                    error.illegalBreak(node.position);
                }
                breakPositions.add(instructions.length);
                emit(OpCode.Jump, node.position, [0]);
            case NodeType.Continue:
                if (loopPositions.isEmpty()) {
                    error.illegalContinue(node.position);
                }
                emit(OpCode.Jump, node.position, [loopPositions.first()]);
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
                final left = symbolTable.defineInternal();
                emit(OpCode.Store, node.position, [left]);
                compile(cOperator.right);
                final right = symbolTable.defineInternal();
                emit(OpCode.Store, node.position, [right]);
                emit(OpCode.Load, node.position, [left]);
                emit(OpCode.Load, node.position, [right]);
                if (node.type == NodeType.LessThanOrEqual) {
                    emit(OpCode.LessThan, node.position, []);
                } else {
                    emit(OpCode.GreaterThan, node.position, []);
                }
                final jumpPeekInstructionPos = instructions.length;
                emit(OpCode.JumpPeek, node.position, [0]);
                emit(OpCode.Pop, node.position, []);
                emit(OpCode.Load, node.position, [left]);
                emit(OpCode.Load, node.position, [right]);
                emit(OpCode.Equals, node.position, []);
                overwriteInstruction(jumpPeekInstructionPos, [instructions.length]);
            case NodeType.Add | NodeType.Multiply | NodeType.Equals | NodeType.LessThan | NodeType.GreaterThan 
                | NodeType.Subtract | NodeType.Divide | NodeType.Modulo | NodeType.ConcatString | NodeType.NotEquals
                | NodeType.BitAnd | NodeType.BitOr | NodeType.BitShiftLeft | NodeType.BitShiftRight | NodeType.BitXor:

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
                    case NodeType.BitAnd: emit(OpCode.BitAnd, node.position, []);
                    case NodeType.BitOr: emit(OpCode.BitOr, node.position, []);
                    case NodeType.BitShiftLeft: emit(OpCode.BitShiftLeft, node.position, []);
                    case NodeType.BitShiftRight: emit(OpCode.BitShiftRight, node.position, []);
                    case NodeType.BitXor: emit(OpCode.BitXor, node.position, []);
                    case NodeType.NotEquals:
                        emit(OpCode.Equals, node.position, []);
                        emit(OpCode.Not, node.position, []);
                    default:
                }
            case NodeType.Negate | NodeType.Not | NodeType.BitNot:
                final cOperator = cast(node, OperatorNode);
                compile(cOperator.right);
                switch (cOperator.type) {
                    case NodeType.Not: emit(OpCode.Not, node.position, []);
                    case NodeType.BitNot: emit(OpCode.BitNot, node.position, []);
                    case NodeType.Negate: emit(OpCode.Negate, node.position, []);
                    default:
                }
            case NodeType.Variable:
                final cVariable = cast(node, VariableNode);

                inline function declareVariable(name:String, mutable:Bool):Symbol {
                    if (symbolTable.currentScope.exists(name)) {
                        error.redeclareVariable(cVariable.position, name);
                    }

                    return symbolTable.define(name, mutable);
                }
        
                if (cVariable.name.type == NodeType.Ident) {
                    final cVariableName = cast(cVariable.name, IdentNode).value;
                    final variableStart = instructions.length;
                    final symbol = declareVariable(cVariableName, cVariable.mutable);
                    if (cVariable.value != null) {
                        compile(cVariable.value);
                    }

                    emit(OpCode.Store, cVariable.position, [symbol.index]);

                    if (debug) {
                        variableTable.define(variableStart, instructions.length, cVariableName);
                    }
                } else if (cVariable.name.type == NodeType.DestructureArray) {
                    final cVariableName = cast(cVariable.name, DestructureArrayNode);

                    if (cVariable.value != null) {
                        compile(cVariable.value);
                    }

                    for (i => varName in cVariableName.names) {
                        final variableStart = instructions.length;

                        final symbol = declareVariable(varName, cVariable.mutable);

                        emit(OpCode.DestructureArray, node.position, [i]);                        
                        emit(OpCode.Store, cVariable.position, [symbol.index]);  

                        if (debug) {
                            variableTable.define(variableStart, instructions.length, varName);
                        }
                    }

                    emit(OpCode.Pop, node.position, []);
                } else {
                    final cVariableName = cast(cVariable.name, DestructureHashNode);

                    if (cVariable.value != null) {
                        compile(cVariable.value);
                    }

                    for (varName in cVariableName.names) {
                        final variableStart = instructions.length;

                        final symbol = declareVariable(varName, cVariable.mutable);

                        emit(OpCode.Constant, node.position, [constantPool.addConstant(new StringObj(varName, null))]);
                        emit(OpCode.DestructureHash, node.position, []);                        
                        emit(OpCode.Store, cVariable.position, [symbol.index]);
                        
                        if (debug) {
                            variableTable.define(variableStart, instructions.length, varName);
                        }
                    }

                    emit(OpCode.Pop, node.position, []);  
                }
            case NodeType.VariableAssign:
                final cVariableAssign = cast(node, VariableAssignNode);

                final variableStart = instructions.length;
                final symbol = symbolTable.resolve(cVariableAssign.name.value);
                if (symbol == null) {
                    error.symbolUndefined(cVariableAssign.position, cVariableAssign.name.value);
                } else if (!symbol.mutable) {
                    error.symbolImmutable(cVariableAssign.position, cVariableAssign.name.value);
                }
                
                compile(cVariableAssign.value);

                if (debug) {
                    variableTable.define(variableStart, instructions.length, cVariableAssign.name.value);
                }
                emit(OpCode.Store, cVariableAssign.position, [symbol.index]);
            case NodeType.VariableAssignOp:
                final cVariableAssignOp = cast(node, VariableAssignOpNode);

                final variableStart = instructions.length;
                final symbol = symbolTable.resolve(cVariableAssignOp.name.value);
                if (symbol == null) {
                    error.symbolUndefined(cVariableAssignOp.position, cVariableAssignOp.name.value);
                } else if (!symbol.mutable) {
                    error.symbolImmutable(cVariableAssignOp.position, cVariableAssignOp.name.value);
                }
                
                compile(cVariableAssignOp.value);

                if (debug) {
                    variableTable.define(variableStart, instructions.length, cVariableAssignOp.name.value);
                }
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

                functionDepth++;
                constantPool.addConstant(new UserFunctionObj(instructions.length, cFunction.parameters.length, null));

                symbolTable.newScope();
                for (parameter in cFunction.parameters) {
                    final variableStart = instructions.length;
                    final symbol = symbolTable.define(parameter.value, false);
                    emit(OpCode.Store, node.position, [symbol.index]);
                    variableTable.define(variableStart, instructions.length, parameter.value);
                }

                compile(cFunction.block);
                emit(OpCode.Return, node.position, []);

                overwriteInstruction(jumpInstructionPos, [instructions.length]);

                symbolTable.setParent();
                functionDepth--;
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

                if (functionDepth <= 0) {
                    error.illegalReturn(node.position);
                }

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
            case NodeType.When:
                final cWhen = cast(node, WhenNode);

                var condition = 0;
                if (cWhen.condition != null) {
                    compile(cWhen.condition);
                    condition = symbolTable.defineInternal();
                    emit(OpCode.Store, node.position, [condition]);
                }

                final jumpPositions:Array<Int> = [];
                for (c in cWhen.cases) {
                    compile(c.condition);

                    if (cWhen.condition != null) {
                        emit(OpCode.Load, node.position, [condition]);
                        emit(OpCode.Equals, node.position, []);
                    }
                    
                    final jumpNotPos = instructions.length;
                    emit(OpCode.JumpNot, node.position, [0]);
                    compile(c.consequence);
                    jumpPositions.push(instructions.length);
                    emit(OpCode.Jump, node.position, [0]);

                    overwriteInstruction(jumpNotPos, [instructions.length]);
                }
                if (cWhen.elseCase != null) {
                    compile(cWhen.elseCase);
                }

                for (pos in jumpPositions) {
                    overwriteInstruction(pos, [instructions.length]);
                }
            case NodeType.For:
                final cFor = cast(node, ForNode);

                compile(cFor.iterator);
                emit(OpCode.Constant, node.position, [constantPool.addConstant(new StringObj("Iterator", null))]);
                emit(OpCode.LoadIndex, node.position, []);
                emit(OpCode.Call, node.position, [0]);
                final iterator = symbolTable.defineInternal();
                emit(OpCode.Store, node.position, [iterator]);

                final jumpPos = instructions.length;
                loopPositions.add(jumpPos);
                emit(OpCode.Load, node.position, [iterator]);
                emit(OpCode.Constant, node.position, [constantPool.addConstant(new StringObj("hasNext", null))]);
                emit(OpCode.LoadIndex, node.position, []);
                emit(OpCode.Call, node.position, [0]);
                final jumpNotPos = instructions.length;
                emit(OpCode.JumpNot, node.position, [0]);
                emit(OpCode.Load, node.position, [iterator]);
                emit(OpCode.Constant, node.position, [constantPool.addConstant(new StringObj("next", null))]);
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

                while (!breakPositions.isEmpty()) {
                    overwriteInstruction(breakPositions.pop(), [instructions.length]);   
                }

                loopPositions.pop();
                overwriteInstruction(jumpNotPos, [instructions.length]);
            case NodeType.While:
                final cWhile = cast(node, WhileNode);

                final jumpPos = instructions.length;
                loopPositions.add(jumpPos);
                compile(cWhile.condition);

                final jumpNotInstructionPos = instructions.length;
                emit(OpCode.JumpNot, node.position, [0]);
                compile(cWhile.block);
                emit(OpCode.Jump, node.position, [jumpPos]);

                while (!breakPositions.isEmpty()) {
                    overwriteInstruction(breakPositions.pop(), [instructions.length]);   
                }

                loopPositions.pop();
                overwriteInstruction(jumpNotInstructionPos, [instructions.length]);
            case NodeType.Float | NodeType.Boolean | NodeType.String | NodeType.Null:
                final constantIndex = switch (node.type) {
                    case NodeType.Float:
                        constantPool.addConstant(new NumberObj(cast(node, FloatNode).value, null));
                    case NodeType.Boolean:
                        constantPool.addConstant(new BooleanObj(cast(node, BooleanNode).value, null));
                    case NodeType.String:
                        constantPool.addConstant(new StringObj(cast(node, StringNode).value, null));
                    case NodeType.Null:
                        constantPool.addConstant(new NullObj(null));
                    default: 0;
                }

                emit(OpCode.Constant, node.position, [constantIndex]);
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