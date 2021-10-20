package compiler;

import lexer.Position;
import haxe.ds.GenericStack;
import object.BooleanObj;
import compiler.symbol.Symbol;
import object.NullObj;
import object.StringObj;
import object.NumberObj;
import object.UserFunctionObj;
import haxe.zip.Compress;
import compiler.debug.FileNameTable;
import std.BuiltInTable;
import haxe.io.Bytes;
import compiler.constant.ConstantPool;
import haxe.io.BytesOutput;
import compiler.debug.VariableTable;
import compiler.debug.LineNumberTable;
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
    final fileNameTable = new FileNameTable();
    var error:CompileError = new CompileError("", "");

    final debug:Bool;
    final warnings:Bool;

    final breakPositions:GenericStack<Int> = new GenericStack();
    final loopPositions:GenericStack<Int> = new GenericStack();
    var functionDepth = 0;

    public function new(debug:Bool, warnings:Bool) {
        this.debug = debug;
        this.warnings = warnings;
    }

    public function getByteCode(compress:Bool):Bytes {
        final program = new BytesOutput();
        program.write(fileNameTable.toByteCode());
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

    function compileFile(node:FileNode) {
        final pFileName = error.fileName;
        final pCode = error.code;

        error.fileName = node.fileName;
        error.code = node.code;

        final startIndex = instructions.length;

        for (n in node.body) {
            compile(n);
        }

        error.fileName = pFileName;
        error.code = pCode;

        if (debug) {
            fileNameTable.define(startIndex, instructions.length, node.fileName);
        }
    }

    function compileBlock(node:BlockNode) {
        symbolTable.newScope();

        for (n in node.body) {
            compile(n);
        }

        symbolTable.setParent();
    }

    function compileHash(node:HashNode) {
        var length = 0;

        for (key => value in node.values) {
            compile(key);
            compile(value);
            length++;
        }

        emit(OpCode.Hash, node.position, [length]);
    }

    function compileArray(node:ArrayNode) {
        var i = node.values.length;
        while (--i >= 0) {
            compile(node.values[i]);
        }

        emit(OpCode.Array, node.position, [node.values.length]);
    }

    function compileRange(node:RangeNode) {
        compile(node.end);
        compile(node.start);
        emit(OpCode.LoadBuiltIn, node.position, [BuiltInTable.resolveName("Range")]);
        final constantIndex = if (node.inclusive) {
            constantPool.addConstant(new StringObj("inclusive", null));
        } else {
            constantPool.addConstant(new StringObj("exclusive", null));
        }
        emit(OpCode.Constant, node.position, [constantIndex]);
        emit(OpCode.LoadIndex, node.position, []);
        emit(OpCode.Call, node.position, [2]);
    }

    function compileRegex(node:RegexNode) {
        compile(node.flags);
        compile(node.pattern);
        emit(OpCode.LoadBuiltIn, node.position, [BuiltInTable.resolveName("Regex")]);
        emit(OpCode.Constant, node.position, [constantPool.addConstant(new StringObj("compile", null))]);
        emit(OpCode.LoadIndex, node.position, []);
        emit(OpCode.Call, node.position, [2]);
    }

    function compileIndex(node:IndexNode) {
        compile(node.target);
        compile(node.index);

        emit(OpCode.LoadIndex, node.position, []);
    }

    function compileIndexAssign(node:IndexAssignNode) {
        compile(node.index);
        removeLastInstruction();
        compile(node.value);

        emit(OpCode.StoreIndex, node.position, []);
    }

    function compileBreak(node:BreakNode) {
        if (loopPositions.isEmpty()) {
            error.illegalBreak(node.position);
        }

        breakPositions.add(instructions.length);
        emit(OpCode.Jump, node.position, [0]);
    }

    function compileContinue(node:ContinueNode) {
        if (loopPositions.isEmpty()) {
            error.illegalContinue(node.position);
        }

        emit(OpCode.Jump, node.position, [loopPositions.first()]);
    }

    function compileStatement(node:StatementNode) {
        compile(node.value.value);
        emit(OpCode.Pop, node.position, []);
    }

    function compileExpression(node:ExpressionNode) {
        compile(node.value);
    }

    function compileOr(node:OperatorNode) {
        compile(node.left);
        final jumpIfLeftPos = instructions.length;
        emit(OpCode.JumpTrue, node.position, [0]);
        compile(node.right);
        final jumpAfterRightPos = instructions.length;
        emit(OpCode.Jump, node.position, [0]);
        overwriteInstruction(jumpIfLeftPos, [instructions.length]);
        emit(OpCode.Constant, node.position, [constantPool.addConstant(new BooleanObj(true, null))]);
        overwriteInstruction(jumpAfterRightPos, [instructions.length]);
    }

    function compileAnd(node:OperatorNode) {
        compile(node.left);
        final jumpIfNotLeftPos = instructions.length;
        emit(OpCode.JumpFalse, node.position, [0]);
        compile(node.right);
        final jumpAfterRightPos = instructions.length;
        emit(OpCode.Jump, node.position, [0]);
        overwriteInstruction(jumpIfNotLeftPos, [instructions.length]);
        emit(OpCode.Constant, node.position, [constantPool.addConstant(new BooleanObj(false, null))]);
        overwriteInstruction(jumpAfterRightPos, [instructions.length]);
    }

    function compileAdd(node:OperatorNode) {
        compile(node.left);
        compile(node.right);
        emit(OpCode.Add, node.position, []);
    }

    function compileSubtract(node:OperatorNode) {
        compile(node.left);
        compile(node.right);
        emit(OpCode.Subtract, node.position, []);
    }

    function compileMultiply(node:OperatorNode) {
        compile(node.left);
        compile(node.right);
        emit(OpCode.Multiply, node.position, []);
    }

    function compileDivide(node:OperatorNode) {
        compile(node.left);
        compile(node.right);
        emit(OpCode.Divide, node.position, []);
    }

    function compileModulo(node:OperatorNode) {
        compile(node.left);
        compile(node.right);
        emit(OpCode.Modulo, node.position, []);   
    }

    function compileEquals(node:OperatorNode) {
        compile(node.left);
        compile(node.right);
        emit(OpCode.Equals, node.position, []);
    }

    function compileNotEquals(node:OperatorNode) {
        compile(node.left);
        compile(node.right);
        emit(OpCode.NotEquals, node.position, []);
    }

    function compileLessThan(node:OperatorNode) {
        compile(node.left);
        compile(node.right);
        emit(OpCode.LessThan, node.position, []);
    }

    function compileGreaterThan(node:OperatorNode) {
        compile(node.left);
        compile(node.right);
        emit(OpCode.GreaterThan, node.position, []);
    }

    function compileLessThanOrEqual(node:OperatorNode) {
        compile(node.left);
        compile(node.right);
        emit(OpCode.LessThanOrEqual, node.position, []);
    }

    function compileGreaterThanOrEqual(node:OperatorNode) {
        compile(node.left);
        compile(node.right);
        emit(OpCode.GreaterThanOrEqual, node.position, []);
    }

    function compileConcatString(node:OperatorNode) {
        compile(node.left);
        compile(node.right);
        emit(OpCode.ConcatString, node.position, []);
    }

    function compileBitAnd(node:OperatorNode) {
        compile(node.left);
        compile(node.right);
        emit(OpCode.BitAnd, node.position, []);
    }

    function compileBitOr(node:OperatorNode) {
        compile(node.left);
        compile(node.right);
        emit(OpCode.BitOr, node.position, []);    
    }

    function compileBitShiftLeft(node:OperatorNode) {
        compile(node.left);
        compile(node.right);
        emit(OpCode.BitShiftLeft, node.position, []);    
    }

    function compileBitShiftRight(node:OperatorNode) {
        compile(node.left);
        compile(node.right);
        emit(OpCode.BitShiftRight, node.position, []);    
    }

    function compileBitXor(node:OperatorNode) {
        compile(node.left);
        compile(node.right);
        emit(OpCode.BitXor, node.position, []);    
    }

    function compileNot(node:OperatorNode) {
        compile(node.right);
        emit(OpCode.Not, node.position, []);
    }

    function compileNegate(node:OperatorNode) {
        compile(node.right);
        emit(OpCode.Negate, node.position, []);
    }

    function compileBitNot(node:OperatorNode) {
        compile(node.right);
        emit(OpCode.BitNot, node.position, []);   
    }

    function compileVariable(node:VariableNode) {
        inline function declareVariable(name:String, mutable:Bool):Symbol {
            if (warnings && StringTools.contains(name, "$")) {
                error.dollarVariableName(node.position, name);
            }
            if (symbolTable.currentScope.exists(name)) {
                error.redeclareVariable(node.position, name);
            }

            return symbolTable.define(name, mutable);
        }

        if (node.name.type == NodeType.Ident) {
            final cVariableName = cast(node.name, IdentNode).value;
            final variableStart = instructions.length;
            if (node.value != null) {
                compile(node.value);
            }

            final symbol = declareVariable(cVariableName, node.mutable);
            emit(OpCode.Store, node.position, [symbol.index]);

            if (debug) {
                variableTable.define(symbol.index, variableStart, instructions.length, cVariableName);
            }
        } else if (node.name.type == NodeType.DestructureArray) {
            final cVariableName = cast(node.name, DestructureArrayNode);

            if (node.value != null) {
                compile(node.value);
            }

            final target = symbolTable.defineInternal();
            emit(OpCode.Store, node.position, [target]);

            for (i => varName in cVariableName.names) {
                final variableStart = instructions.length;

                final symbol = declareVariable(varName, node.mutable);
                
                emit(OpCode.Load, node.position, [target]);  
                emit(OpCode.Constant, node.position, [constantPool.addConstant(new NumberObj(i, null))]);
                emit(OpCode.LoadIndex, node.position, []);   
                emit(OpCode.Store, node.position, [symbol.index]);  

                if (debug) {
                    variableTable.define(symbol.index, variableStart, instructions.length, varName);
                }
            }
        } else {
            final cVariableName = cast(node.name, DestructureHashNode);

            if (node.value != null) {
                compile(node.value);
            }

            final target = symbolTable.defineInternal();
            emit(OpCode.Store, node.position, [target]);

            for (varName in cVariableName.names) {
                final variableStart = instructions.length;

                final symbol = declareVariable(varName, node.mutable);

                emit(OpCode.Load, node.position, [target]);  
                emit(OpCode.Constant, node.position, [constantPool.addConstant(new StringObj(varName, null))]);
                emit(OpCode.LoadIndex, node.position, []);                 
                emit(OpCode.Store, node.position, [symbol.index]);
                
                if (debug) {
                    variableTable.define(symbol.index, variableStart, instructions.length, varName);
                }
            } 
        }
    }

    function compileVariableAssign(node:VariableAssignNode) {
        final variableStart = instructions.length;
        final symbol = symbolTable.resolve(node.name.value);
        if (symbol == null) {
            error.symbolUndefined(node.position, node.name.value);
        } else if (!symbol.mutable) {
            error.symbolImmutable(node.position, node.name.value);
        }
        
        compile(node.value);

        emit(OpCode.Store, node.position, [symbol.index]);

        if (debug) {
            variableTable.define(symbol.index, variableStart, instructions.length, node.name.value);
        }
    }

    function compileIdent(node:IdentNode) {
        final symbol = symbolTable.resolve(node.value);

        if (symbol == null) {
            final builtInIndex = BuiltInTable.resolveName(node.value);

            if (builtInIndex != -1) {
                emit(OpCode.LoadBuiltIn, node.position, [builtInIndex]);
            } else {
                error.symbolUndefined(node.position, node.value);
            }
        } else {
            emit(OpCode.Load, node.position, [symbol.index]);     
        }
    }

    function compileFunction(node:FunctionNode) {
        emit(OpCode.Constant, node.position, [constantPool.getSize()]);

        final jumpInstructionPos = instructions.length;
        emit(OpCode.Jump, node.position, [0]);

        functionDepth++;
        constantPool.addConstant(new UserFunctionObj(instructions.length, node.parameters.length, null));

        symbolTable.newScope();
        for (parameter in node.parameters) {
            if (symbolTable.currentScope.exists(parameter.ident.value)) {
                error.redeclareVariable(parameter.position, parameter.ident.value);
            }
            final variableStart = instructions.length;
            final symbol = symbolTable.define(parameter.ident.value, parameter.mutable);
            emit(OpCode.Store, node.position, [symbol.index]);
            if (debug) {
                variableTable.define(symbol.index, variableStart, instructions.length, parameter.ident.value);
            }
        }

        compile(node.block);
        emit(OpCode.Return, node.position, []);

        overwriteInstruction(jumpInstructionPos, [instructions.length]);

        symbolTable.setParent();
        functionDepth--;
    }

    function compileFunctionCall(node:CallNode) {                
        var i = node.parameters.length;
        while (--i >= 0) {
            compile(node.parameters[i]);
        }

        compile(node.target);

        emit(OpCode.Call, node.position, [node.parameters.length]);
    }

    function compileReturn(node:ReturnNode) {
        if (functionDepth <= 0) {
            error.illegalReturn(node.position);
        }

        if (node.value != null) {
            compile(node.value);
        }
        
        emit(OpCode.Return, node.position, []);
    }

    function compileIf(node:IfNode) {
        compile(node.condition);

        final JumpFalseInstructionPos = instructions.length;
        emit(OpCode.JumpFalse, node.position, [0]);

        compile(node.consequence);

        final jumpInstructionPos = instructions.length;
        emit(OpCode.Jump, node.position, [0]);

        final JumpFalsePos = instructions.length;
        if (node.alternative != null) {
            compile(node.alternative);
        }
        final jumpPos = instructions.length;

        overwriteInstruction(JumpFalseInstructionPos, [JumpFalsePos]);
        overwriteInstruction(jumpInstructionPos, [jumpPos]);
    }

    function compileWhen(node:WhenNode) {
        var condition = 0;
        if (node.condition != null) {
            compile(node.condition);
            condition = symbolTable.defineInternal();
            emit(OpCode.Store, node.position, [condition]);
        }

        final jumpPositions:Array<Int> = [];
        for (c in node.cases) {
            compile(c.condition);

            if (node.condition != null) {
                emit(OpCode.Load, node.position, [condition]);
                emit(OpCode.Equals, node.position, []);
            }
            
            final JumpFalsePos = instructions.length;
            emit(OpCode.JumpFalse, node.position, [0]);
            compile(c.consequence);
            jumpPositions.push(instructions.length);
            emit(OpCode.Jump, node.position, [0]);

            overwriteInstruction(JumpFalsePos, [instructions.length]);
        }
        if (node.elseCase != null) {
            compile(node.elseCase);
        }

        for (pos in jumpPositions) {
            overwriteInstruction(pos, [instructions.length]);
        }
    }

    function compileFor(node:ForNode) {
        compile(node.iterator);
        emit(OpCode.Constant, node.position, [constantPool.addConstant(new StringObj("Iterator", null))]);
        emit(OpCode.LoadIndex, node.position, []);
        emit(OpCode.Call, node.position, [0]);
        final iterator = symbolTable.defineInternal();
        emit(OpCode.Store, node.position, [iterator]);

        final jumpSkipPos = instructions.length;
        loopPositions.add(jumpSkipPos);
        emit(OpCode.Jump, node.position, [jumpSkipPos]);
        final blockStartPos = instructions.length;
        emit(OpCode.Load, node.position, [iterator]);
        emit(OpCode.Constant, node.position, [constantPool.addConstant(new StringObj("next", null))]);
        emit(OpCode.LoadIndex, node.position, []);
        emit(OpCode.Call, node.position, [0]);
        symbolTable.newScope();
        if (node.variable != null) {
            compile(node.variable);
        } else {
            emit(OpCode.Pop, node.position, []);
        }
        compile(node.block);
        symbolTable.setParent();
        overwriteInstruction(jumpSkipPos, [instructions.length]);
        emit(OpCode.Load, node.position, [iterator]);
        emit(OpCode.Constant, node.position, [constantPool.addConstant(new StringObj("hasNext", null))]);
        emit(OpCode.LoadIndex, node.position, []);
        emit(OpCode.Call, node.position, [0]);
        emit(OpCode.JumpTrue, node.position, [blockStartPos]);

        while (!breakPositions.isEmpty()) {
            overwriteInstruction(breakPositions.pop(), [instructions.length]);   
        }

        loopPositions.pop();
    }

    function compileWhile(node:WhileNode) {
        final jumpSkipPos = instructions.length;
        loopPositions.add(jumpSkipPos);
        emit(OpCode.Jump, node.position, [jumpSkipPos]);
        final blockStartPos = instructions.length;
        compile(node.block);
        overwriteInstruction(jumpSkipPos, [instructions.length]);
        compile(node.condition);
        emit(OpCode.JumpTrue, node.position, [blockStartPos]);

        while (!breakPositions.isEmpty()) {
            overwriteInstruction(breakPositions.pop(), [instructions.length]);   
        }

        loopPositions.pop();
    }

    public function compile(node:Node) {
        switch(node.type) {
            case NodeType.File: compileFile(cast(node, FileNode));
            case NodeType.Block: compileBlock(cast(node, BlockNode));
            case NodeType.Hash: compileHash(cast(node, HashNode));
            case NodeType.Array: compileArray(cast(node, ArrayNode));
            case NodeType.Range: compileRange(cast(node, RangeNode));
            case NodeType.Regex: compileRegex(cast(node, RegexNode));
            case NodeType.Index: compileIndex(cast(node, IndexNode));
            case NodeType.IndexAssign: compileIndexAssign(cast(node, IndexAssignNode));
            case NodeType.Break: compileBreak(cast(node, BreakNode));
            case NodeType.Continue: compileContinue(cast(node, ContinueNode));
            case NodeType.Statement: compileStatement(cast(node, StatementNode));
            case NodeType.Expression: compileExpression(cast(node, ExpressionNode));
            case NodeType.Or: compileOr(cast(node, OperatorNode));
            case NodeType.And: compileAnd(cast(node, OperatorNode));
            case NodeType.Add: compileAdd(cast(node, OperatorNode));
            case NodeType.Subtract: compileSubtract(cast(node, OperatorNode));
            case NodeType.Multiply: compileMultiply(cast(node, OperatorNode));
            case NodeType.Divide: compileDivide(cast(node, OperatorNode));
            case NodeType.Modulo: compileModulo(cast(node, OperatorNode));
            case NodeType.Equals: compileEquals(cast(node, OperatorNode));
            case NodeType.NotEquals: compileNotEquals(cast(node, OperatorNode));
            case NodeType.LessThan: compileLessThan(cast(node, OperatorNode));
            case NodeType.GreaterThan: compileGreaterThan(cast(node, OperatorNode));
            case NodeType.LessThanOrEqual: compileLessThanOrEqual(cast(node, OperatorNode));
            case NodeType.GreaterThanOrEqual: compileGreaterThanOrEqual(cast(node, OperatorNode));
            case NodeType.ConcatString: compileConcatString(cast(node, OperatorNode));
            case NodeType.BitAnd: compileBitAnd(cast(node, OperatorNode));
            case NodeType.BitOr: compileBitOr(cast(node, OperatorNode));
            case NodeType.BitShiftLeft: compileBitShiftLeft(cast(node, OperatorNode));
            case NodeType.BitShiftRight: compileBitShiftRight(cast(node, OperatorNode));
            case NodeType.BitXor: compileBitXor(cast(node, OperatorNode));
            case NodeType.Not: compileNot(cast(node, OperatorNode));
            case NodeType.Negate: compileNegate(cast(node, OperatorNode));
            case NodeType.BitNot: compileBitNot(cast(node, OperatorNode));
            case NodeType.Variable: compileVariable(cast(node, VariableNode));
            case NodeType.VariableAssign: compileVariableAssign(cast(node, VariableAssignNode));
            case NodeType.Ident: compileIdent(cast(node, IdentNode));
            case NodeType.Function: compileFunction(cast(node, FunctionNode));
            case NodeType.FunctionCall: compileFunctionCall(cast(node, CallNode));
            case NodeType.Return: compileReturn(cast(node, ReturnNode));
            case NodeType.If: compileIf(cast(node, IfNode));
            case NodeType.When: compileWhen(cast(node, WhenNode));
            case NodeType.For: compileFor(cast(node, ForNode));
            case NodeType.While: compileWhile(cast(node, WhileNode));
            case NodeType.Float | NodeType.Boolean | NodeType.String | NodeType.Null:
                final constantIndex = switch (node.type) {
                    case NodeType.Float:
                        constantPool.addConstant(new NumberObj(cast(node, NumberNode).value, null));
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

    function emit(op:Int, position:Position, operands:Array<Int>) {
        if (debug) {
            lineNumberTable.define(instructions.length, position);
        }
        final instruction = Code.make(op, operands);
        
        instructions.write(instruction);
    }
}