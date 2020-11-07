package evaluator;

import object.*;
import haxe.zip.Uncompress;
import compiler.debug.FilenameTable;
import haxe.ds.StringMap;
import object.Object;
import compiler.constant.ConstantPool;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import compiler.debug.VariableTable;
import error.RuntimeError;
import compiler.debug.LineNumberTable;
import std.BuiltInTable;
import code.OpCode;
import haxe.ds.GenericStack;

using equals.Equal;

class Evaluator {

    public final stack:GenericStack<Object> = new GenericStack();
    public var frames:GenericStack<Frame> = new GenericStack();
    public var currentFrame:Frame;
    var constantPool:Array<Object>;
    var instructions:BytesInput;
    var filenameTable:FilenameTable;
    var lineNumberTable:LineNumberTable;
    var variableTable:VariableTable;
    final builtInTable:BuiltInTable;
    public final error:RuntimeError;

    public function new(fileData:Bytes) {
        newWithState(fileData);
        builtInTable = new BuiltInTable(this);

        error = new RuntimeError(frames, lineNumberTable, variableTable, filenameTable, instructions);
        frames.add(new Frame(null, 0, null));
        currentFrame = frames.first();
    }

    public function newWithState(fileData:Bytes) {
        final fileData = new BytesInput(fileData);
        final byteCode = if (fileData.readByte() == 1) {
            new BytesInput(Uncompress.run(fileData.readAll()));
        } else {
            new BytesInput(fileData.readAll());
        }
        filenameTable = new FilenameTable().fromByteCode(byteCode);
        lineNumberTable = new LineNumberTable().fromByteCode(byteCode);
        variableTable = new VariableTable().fromByteCode(byteCode);
        constantPool = ConstantPool.fromByteCode(byteCode, this);
        final oPosition = instructions != null ? instructions.position : -1;
        instructions = new BytesInput(byteCode.read(byteCode.readInt32()));
        if (oPosition != -1) {
            instructions.position = oPosition;
        }
    }

    public function callFunction(closure:ClosureObj, parameters:Array<Object>) {
        parameters.reverse();

        for (p in parameters) {
            stack.add(p);
        }

        switch (closure.func.type) {
            case ObjectType.UserFunction:
                final cUserFunction = cast(closure.func, UserFunctionObj);

                if (parameters.length != cUserFunction.parametersCount) {
                    error.error("wrong number of arguments to function");
                }
                final oPosition = instructions.position;
                frames.add(new Frame(closure.context, instructions.length, cUserFunction));
                currentFrame = frames.first();
                instructions.position = cUserFunction.position;
                eval();
                instructions.position = oPosition;
            default:
        }

        return stack.pop();
    }

    public function eval() {
        while (instructions.position < instructions.length) {
            evalInstruction();
        }
    }

    function evalInstruction() {
        final opCode = instructions.readByte();
        
        switch (opCode) {
            case OpCode.Array:
                final arrayLength = instructions.readInt32();
                final arrayValues:Array<Object> = [];

                for (_ in 0...arrayLength) {
                    arrayValues.unshift(stack.pop());
                }

                stack.add(new ArrayObj(arrayValues, this));
            case OpCode.Hash:
                final hashLength = instructions.readInt32();
                final hashValues:StringMap<Object> = new StringMap();

                for (_ in 0...hashLength) {
                    final value = stack.pop();
                    final key = stack.pop();

                    if (key.type == ObjectType.String) {
                        hashValues.set(cast(key, StringObj).value, value);
                    } else {
                        error.error("hash key must be a string");   
                    }
                }

                stack.add(new HashObj(hashValues, this));
            case OpCode.DestructureArray:
                final target = stack.first();
                final destructureIndex = instructions.readInt32();

                if (target.type == ObjectType.Array) {
                    final cTarget = cast(target, ArrayObj);

                    final value = cTarget.value[destructureIndex]; 
                    stack.add(value == null ? new NullObj(this) : value); 
                } else {
                    error.error("cannot destructure object");
                }
            case OpCode.DestructureHash:
                final index = stack.pop();
                final target = stack.first();

                if (target.type == ObjectType.Hash) {
                    final cTarget = cast(target, HashObj);
                    final cIndex = cast(index, StringObj);

                    final value = cTarget.value.get(cIndex.value); 
                    stack.add(value == null ? new NullObj(this) : value); 
                } else {
                    error.error("cannot destructure object");
                }  
            case OpCode.LoadIndex:
                final index = stack.pop();
                final target = stack.pop();

                final value = switch [target.type, index.type] {
                    case [ObjectType.Array, ObjectType.Number]:
                        final cTarget = cast(target, ArrayObj);
                        final cIndex = cast(index, NumberObj);

                        cTarget.value[Std.int(cIndex.value)];
                    case [ObjectType.Hash, ObjectType.String]:
                        final cTarget = cast(target, HashObj);
                        final cIndex = cast(index, StringObj);

                        var value = cTarget.value.get(cIndex.value);
                        if (value == null) {
                            value = cTarget.getMembers().value.get(cIndex.value);
                        }

                        value;
                    case [_, ObjectType.String]:
                        final cIndex = cast(index, StringObj);

                        target.getMembers().value.get(cIndex.value);
                    default: new NullObj(this);
                }

                stack.add(value == null ? new NullObj(this) : value);
            case OpCode.StoreIndex:
                final value = stack.pop();
                final index = stack.pop();
                final target = stack.pop();

                switch [target.type, index.type] {
                    case [ObjectType.Array, ObjectType.Number]:
                        final cTarget = cast(target, ArrayObj);
                        final cIndex = cast(index, NumberObj);

                        cTarget.value[Std.int(cIndex.value)] = value;
                    case [ObjectType.Hash, ObjectType.String]:
                        final cTarget = cast(target, HashObj);
                        final cIndex = cast(index, StringObj);

                        cTarget.value.set(cIndex.value, value);
                    case [_, ObjectType.String]:
                        final cIndex = cast(index, StringObj);
    
                        target.getMembers().value.set(cIndex.value, value);
                    default: 
                        error.error("index operator cannot be used on this datatype");      
                }
            case OpCode.ConcatString:
                final right = stack.pop().toString();
                final left = stack.pop().toString();

                stack.add(new StringObj('$left$right', this));
            case OpCode.Add | OpCode.Multiply | OpCode.LessThan | OpCode.GreaterThan | OpCode.Subtract | OpCode.Divide | OpCode.Modulo:
                final right = stack.pop();
                final left = stack.pop();

                if (left.type != ObjectType.Number || right.type != ObjectType.Number) {
                    error.error("cannot perform operation");  
                }

                final cLeft = cast(left, NumberObj).value;
                final cRight = cast(right, NumberObj).value;

                final result = switch (opCode) {
                    case OpCode.Add: cLeft + cRight;
                    case OpCode.Subtract: cLeft - cRight;
                    case OpCode.Multiply: cLeft * cRight;
                    case OpCode.Divide: cLeft / cRight;
                    case OpCode.Modulo: cLeft % cRight;
                    case OpCode.LessThan: cLeft < cRight ? 1 : 0;
                    case OpCode.GreaterThan: cLeft > cRight ? 1 : 0;
                    default: -1;
                };

                stack.add(new NumberObj(result, this));
            case OpCode.Equals:
                final right = stack.pop();
                final left = stack.pop();
                
                final equals = switch [left.type, right.type] {
                    case [ObjectType.Number, ObjectType.Number]:
                        final cLeft = cast(left, NumberObj).value;
                        final cRight = cast(right, NumberObj).value;
                        cLeft == cRight;
                    case [ObjectType.String, ObjectType.String]:
                        final cLeft = cast(left, StringObj).value;
                        final cRight = cast(right, StringObj).value;
                        cLeft == cRight;
                    case [ObjectType.Closure, ObjectType.Closure]:
                        final cLeft = cast(left, ClosureObj).func;
                        final cRight = cast(right, ClosureObj).func;
                        cLeft.equals(cRight);
                    case [ObjectType.Array, ObjectType.Array]:
                        final cLeft = cast(left, ArrayObj).value;
                        final cRight = cast(right, ArrayObj).value;
                        cLeft.equals(cRight);   
                    case [ObjectType.Hash, ObjectType.Hash]:
                        final cLeft = cast(left, HashObj).value;
                        final cRight = cast(right, HashObj).value;
                        cLeft.equals(cRight);
                    case [ObjectType.Null, ObjectType.Null]: true;
                    default: false;
                }

                stack.add(new NumberObj(equals ? 1 : 0, this));
            case OpCode.Constant:
                final constantIndex = instructions.readInt32();

                final constant = switch (constantPool[constantIndex].type) {
                    case ObjectType.UserFunction: new ClosureObj(cast(constantPool[constantIndex], UserFunctionObj), currentFrame,this);
                    default: constantPool[constantIndex];
                }

                stack.add(constant);
            case OpCode.Store:
                final localIndex = instructions.readInt32();

                final value = stack.pop();

                if (value == null) {
                    currentFrame.setVariable(localIndex, new NullObj(this));
                } else {
                    currentFrame.setVariable(localIndex, value);
                }
            case OpCode.Load:
                final localIndex = instructions.readInt32();

                final value = currentFrame.getVariable(localIndex);

                stack.add(value);
            case OpCode.LoadBuiltIn:
                final builtInIndex = instructions.readInt32();

                stack.add(builtInTable.resolveIndex(builtInIndex));
            case OpCode.JumpNot:
                final jumpIndex = instructions.readInt32();
                final conditionValue = cast(stack.pop(), NumberObj).value;

                if (conditionValue == 0) {
                    instructions.position = jumpIndex;
                }
            case OpCode.JumpPeek:
                final jumpIndex = instructions.readInt32();
                final conditionValue = cast(stack.first(), NumberObj).value;

                if (conditionValue == 1) {
                    instructions.position = jumpIndex;
                }
            case OpCode.Jump:
                final jumpIndex = instructions.readInt32();

                instructions.position = jumpIndex;
            case OpCode.Call:
                final callParametersCount = instructions.readInt32();
                final object = stack.pop();

                switch (object.type) {
                    case ObjectType.Closure:
                        final cClosure = cast(object, ClosureObj);
                        frames.add(new Frame(cClosure.context, instructions.position, cClosure.func));
                        currentFrame = frames.first();

                        if (cClosure.func.parametersCount != callParametersCount) {
                            error.error('wrong number of arguments to function. expected ${cClosure.func.parametersCount}, got $callParametersCount');   
                        }

                        switch (cClosure.func.type) {
                            case ObjectType.UserFunction:
                                final cUserFunction = cast(cClosure.func, UserFunctionObj);
                                instructions.position = cUserFunction.position;
                            case ObjectType.BuiltInFunction:
                                final cBuiltInFunction = cast(cClosure.func, BuiltInFunctionObj);
                                builtInTable.callFunction(cBuiltInFunction);
                            default:
                        }
                    default: error.error("object is not a function");
                }
            case OpCode.Return:
                try {
                    instructions.position = frames.pop().returnAddress;
                    currentFrame = frames.first();
                    if (stack.isEmpty()) {
                        stack.add(new NullObj(this));
                    }
                } catch (e) {
                    error.error("illegal return statement");
                }
            case OpCode.Negate:
                final negValue = stack.pop();

                if (negValue.type == ObjectType.Number) {
                    final value = cast(negValue, NumberObj).value;
                    stack.add(new NumberObj(-value, this));      
                } else {
                    error.error("only floats can be negated");   
                }
            case OpCode.Not:
                final invValue = stack.pop();

                if (invValue.type == ObjectType.Number) {
                    final value = cast(invValue, NumberObj).value;
                    stack.add(new NumberObj(value == 1 ? 0 : 1, this));      
                } else {
                    error.error("only floats can be inverted");   
                }
            case OpCode.Pop:
                stack.pop();

            default:

        }
    }
}