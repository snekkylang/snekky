package evaluator;

import cpp.Object;
import haxe.zip.Uncompress;
import compiler.debug.FilenameTable;
import haxe.ds.StringMap;
import object.Object;
import compiler.constant.ConstantPool;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import compiler.debug.LocalVariableTable;
import error.RuntimeError;
import compiler.debug.LineNumberTable;
import std.BuiltInTable;
import code.OpCode;
import haxe.ds.GenericStack;

using equals.Equal;
using object.ObjectHelper;

class Evaluator {

    public final stack:GenericStack<Object> = new GenericStack();
    public var frames:GenericStack<Frame> = new GenericStack();
    public var currentFrame:Frame;
    final constantPool:Array<Object>;
    final instructions:BytesInput;
    final filenameTable:FilenameTable;
    final lineNumberTable:LineNumberTable;
    final localVariableTable:LocalVariableTable;
    final builtInTable:BuiltInTable;
    public final error:RuntimeError;

    public function new(fileData:Bytes) {
        final fileData = new BytesInput(fileData);
        final byteCode = if (fileData.readByte() == 1) {
            new BytesInput(Uncompress.run(fileData.readAll()));
        } else {
            new BytesInput(fileData.readAll());
        }
        filenameTable = new FilenameTable().fromByteCode(byteCode);
        lineNumberTable = new LineNumberTable().fromByteCode(byteCode);
        localVariableTable = new LocalVariableTable().fromByteCode(byteCode);
        constantPool = ConstantPool.fromByteCode(byteCode);
        instructions = new BytesInput(byteCode.read(byteCode.readInt32()));
        builtInTable = new BuiltInTable(this);

        error = new RuntimeError(frames, lineNumberTable, localVariableTable, filenameTable, instructions);
        frames.add(new Frame(null, 0, Object.Null));
        currentFrame = frames.first();
    }

    public function callFunction(closure:Object, parameters:Array<Object>) {
        parameters.reverse();

        for (p in parameters) {
            stack.add(p);
        }

        switch (closure) {
            case Object.Closure(func, frame):
                switch (func) {
                    case Object.UserFunction(position, parametersCount):
                        if (parameters.length != parametersCount) {
                            error.error("wrong number of arguments to function");
                        }
                        final oPosition = instructions.position;
                        frames.add(new Frame(frame, instructions.length, func));
                        currentFrame = frames.first();
                        instructions.position = position;
                        eval();
                        instructions.position = oPosition;
                    default:
                }
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

                stack.add(Object.Array(arrayValues));
            case OpCode.Hash:
                final hashLength = instructions.readInt32();
                final hashValues:StringMap<Object> = new StringMap();

                for (_ in 0...hashLength) {
                    final value = stack.pop();
                    final key = stack.pop();

                    switch key {
                        case Object.String(keyVal):
                            hashValues.set(keyVal, value);
                        default: error.error("hash key must be a string");
                    }
                }

                stack.add(Object.Hash(hashValues));
            case OpCode.LoadIndex:
                final index = stack.pop();
                final target = stack.pop();

                final value = switch [target, index] {
                    case [Object.Array(array), Object.Number(arrayIndex)]:
                        array[Std.int(arrayIndex)];
                    case [Object.Hash(hash), Object.String(hashIndex)]:
                        hash.get(hashIndex);
                    case [_, Object.String(memberName)]:
                        final members = builtInTable.resolveObject(target);
                        switch (members) {
                            case Object.Hash(values):
                                stack.add(target);
                                values.get(memberName);
                            default: Object.Null;
                        }  
                    default: Object.Null;
                }

                stack.add(value == null ? Object.Null : value);
            case OpCode.StoreIndex:
                final value = stack.pop();
                final index = stack.pop();
                final target = stack.pop();

                switch [target, index] {
                    case [Object.Array(array), Object.Number(arrayIndex)]:
                        array[Std.int(arrayIndex)] = value;
                    case [Object.Hash(hash), Object.String(hashIndex)]:
                        hash.set(hashIndex, value);
                    default: 
                        error.error("index operator cannot be used on this datatype");      
                }
            case OpCode.ConcatString:
                final right = stack.pop().toString();
                final left = stack.pop().toString();

                stack.add(Object.String('$left$right'));
            case OpCode.Add | OpCode.Multiply | OpCode.LessThan | OpCode.GreaterThan | OpCode.Subtract | OpCode.Divide | OpCode.Modulo | OpCode.Equals:
                final right = stack.pop();
                final left = stack.pop();

                final result = switch [opCode, left, right] {
                    case [OpCode.Add, Object.Number(leftVal), Object.Number(rightVal)]: leftVal + rightVal;
                    case [OpCode.Subtract, Object.Number(leftVal), Object.Number(rightVal)]: leftVal - rightVal;
                    case [OpCode.Multiply, Object.Number(leftVal), Object.Number(rightVal)]: leftVal * rightVal;
                    case [OpCode.Divide, Object.Number(leftVal), Object.Number(rightVal)]: leftVal / rightVal;
                    case [OpCode.Modulo, Object.Number(leftVal), Object.Number(rightVal)]: leftVal % rightVal;
                    case [OpCode.LessThan, Object.Number(leftVal), Object.Number(rightVal)]: leftVal < rightVal ? 1 : 0;
                    case [OpCode.GreaterThan, Object.Number(leftVal), Object.Number(rightVal)]: leftVal > rightVal ? 1 : 0;
                    case [OpCode.Equals, Object.Number(leftVal), Object.Number(rightVal)]: leftVal == rightVal ? 1 : 0;
                    case [OpCode.Equals, Object.String(leftVal), Object.String(rightVal)]: leftVal == rightVal ? 1 : 0;
                    case [OpCode.Equals, Object.UserFunction(leftPos, _), Object.UserFunction(rightPos, _)]: leftPos == rightPos ? 1 : 0;
                    case [OpCode.Equals, Object.BuiltInFunction(leftFunc, _), Object.BuiltInFunction(rightFunc, _)]: leftFunc.equals(rightFunc) ? 1 : 0;
                    case [OpCode.Equals, Object.Array(leftVal), Object.Array(rightVal)]: leftVal.equals(rightVal) ? 1 : 0;
                    case [OpCode.Equals, Object.Hash(leftVal), Object.Hash(rightVal)]: leftVal.equals(rightVal) ? 1 : 0;
                    case [OpCode.Equals, Object.Null, Object.Null]: 1;
                    case [OpCode.Equals, _, _]: 0;
                    default:
                        error.error("cannot perform operation");
                        -1;
                }

                stack.add(Object.Number(result));
            case OpCode.Constant:
                final constantIndex = instructions.readInt32();

                final constant = switch (constantPool[constantIndex]) {
                    case Object.UserFunction(_, _): Object.Closure(constantPool[constantIndex], currentFrame);
                    default: constantPool[constantIndex];
                }

                stack.add(constant);
            case OpCode.Store:
                final localIndex = instructions.readInt32();

                final value = stack.pop();

                if (value == null) {
                    currentFrame.setVariable(localIndex, Object.Null);
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
                final conditionValue = stack.pop();

                switch (conditionValue) {
                    case Object.Number(value):
                        if (value == 0) {
                            instructions.position = jumpIndex;
                        }
                    default: 
                }
            case OpCode.JumpPeek:
                final jumpIndex = instructions.readInt32();
                final conditionValue = stack.first();

                switch (conditionValue) {
                    case Object.Number(value):
                        if (value == 1) {
                            instructions.position = jumpIndex;
                        }
                    default: 
                }
            case OpCode.Jump:
                final jumpIndex = instructions.readInt32();

                instructions.position = jumpIndex;
            case OpCode.Call:
                final callParametersCount = instructions.readInt32();
                final object = stack.pop();

                switch (object) {
                    case Object.Closure(func, frame):
                        frames.add(new Frame(frame, instructions.position, object));
                        currentFrame = frames.first();
                        switch (func) {
                            case Object.UserFunction(position, funcParametersCount):
                                if (callParametersCount != funcParametersCount) {
                                    error.error("wrong number of arguments to function");
                                }
                                instructions.position = position;
                            case Object.BuiltInFunction(_, _):
                                builtInTable.callFunction(func);
                            default: error.error("object is not a function");
                        }
                    default: error.error("object is not a function");
                }
            case OpCode.Return:
                instructions.position = frames.pop().returnAddress;
                currentFrame = frames.first();
                if (stack.isEmpty()) {
                    stack.add(Object.Null);
                }
            case OpCode.Negate:
                final negValue = stack.pop();

                switch (negValue) {
                    case Object.Number(value):
                        stack.add(Object.Number(-value));
                    default: error.error("only floats can be negated");
                }
            case OpCode.Not:
                final invValue = stack.pop();

                switch (invValue) {
                    case Object.Number(value):
                        stack.add(Object.Number(value == 1 ? 0 : 1));
                    default: error.error("only floats can be inverted");
                }
            case OpCode.Pop:
                stack.pop();

            default:

        }
    }
}