package evaluator;

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
    public final callStack:GenericStack<ReturnAddress> = new GenericStack();
    final constantPool:Array<Object>;
    final instructions:BytesInput;
    final lineNumberTable:LineNumberTable;
    final localVariableTable:LocalVariableTable;
    final env = new Environment();
    final builtInTable:BuiltInTable;
    public final error:RuntimeError;

    public function new(byteCode:Bytes) {
        final byteCode = new BytesInput(byteCode);
        lineNumberTable = new LineNumberTable().fromByteCode(byteCode);
        localVariableTable = new LocalVariableTable().fromByteCode(byteCode);
        constantPool = ConstantPool.fromByteCode(byteCode);
        instructions = new BytesInput(byteCode.read(byteCode.readInt32()));
        builtInTable = new BuiltInTable(this);

        error = new RuntimeError(callStack, this.lineNumberTable, this.localVariableTable, instructions);
    }

    public function callFunction(func:Object, parameters:Array<Object>) {
        parameters.reverse();

        for (p in parameters) {
            stack.add(p);
        }

        switch (func) {
            case Object.UserFunction(position):
                final oPosition = instructions.position;
                callStack.add(new ReturnAddress(instructions.length, func));
                instructions.position = position;
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

                stack.add(Object.Array(arrayValues));
            case OpCode.Hash:
                final hashLength = instructions.readInt32();
                final hashValues:Map<String, Object> = new Map();

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
                    case [Object.Array(array), Object.Float(arrayIndex)]:
                        array[Std.int(arrayIndex)];
                    case [Object.Hash(hash), Object.String(hashIndex)]:
                        hash.get(hashIndex);
                    default: 
                        error.error("index operator cannot be used on this datatype");      
                        Object.Float(-1);
                }

                if (value == null) {
                    error.error("index out of bounds");
                }

                stack.add(value);
            case OpCode.StoreIndex:
                final value = stack.pop();
                final index = stack.pop();
                final target = stack.pop();

                switch [target, index] {
                    case [Object.Array(array), Object.Float(arrayIndex)]:
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
                    case [OpCode.Add, Object.Float(leftVal), Object.Float(rightVal)]: leftVal + rightVal;
                    case [OpCode.Subtract, Object.Float(leftVal), Object.Float(rightVal)]: leftVal - rightVal;
                    case [OpCode.Multiply, Object.Float(leftVal), Object.Float(rightVal)]: leftVal * rightVal;
                    case [OpCode.Divide, Object.Float(leftVal), Object.Float(rightVal)]: leftVal / rightVal;
                    case [OpCode.Modulo, Object.Float(leftVal), Object.Float(rightVal)]: leftVal % rightVal;
                    case [OpCode.LessThan, Object.Float(leftVal), Object.Float(rightVal)]: leftVal < rightVal ? 1 : 0;
                    case [OpCode.GreaterThan, Object.Float(leftVal), Object.Float(rightVal)]: leftVal > rightVal ? 1 : 0;
                    case [OpCode.Equals, Object.Float(leftVal), Object.Float(rightVal)]: leftVal == rightVal ? 1 : 0;
                    case [OpCode.Equals, Object.String(leftVal), Object.String(rightVal)]: leftVal == rightVal ? 1 : 0;
                    case [OpCode.Equals, Object.UserFunction(leftPos), Object.UserFunction(rightPos)]: leftPos == rightPos ? 1 : 0;
                    case [OpCode.Equals, Object.BuiltInFunction(leftIndex), Object.BuiltInFunction(rightIndex)]: leftIndex == rightIndex ? 1 : 0;
                    case [OpCode.Equals, Object.Array(leftVal), Object.Array(rightVal)]: leftVal.equals(rightVal) ? 1 : 0;
                    case [OpCode.Equals, Object.Hash(leftVal), Object.Hash(rightVal)]: leftVal.equals(rightVal) ? 1 : 0;
                    case [OpCode.Equals, Object.Null, Object.Null]: 1;
                    default:
                        error.error("cannot perform operation");
                        -1;
                }

                stack.add(Object.Float(result));
            case OpCode.Constant:
                final constantIndex = instructions.readInt32();

                stack.add(constantPool[constantIndex]);
            case OpCode.Store:
                final localIndex = instructions.readInt32();

                final value = stack.pop();

                if (value == null) {
                    env.setVariable(localIndex, Object.Null);
                } else {
                    env.setVariable(localIndex, value);
                }
            case OpCode.Load:
                final localIndex = instructions.readInt32();

                final value = env.getVariable(localIndex);

                stack.add(value);
            case OpCode.LoadBuiltIn:
                final builtInIndex = instructions.readInt32();

                stack.add(builtInTable.resolveIndex(builtInIndex));
            case OpCode.JumpNot:
                final jumpIndex = instructions.readInt32();
                final conditionValue = stack.pop();

                switch (conditionValue) {
                    case Object.Float(value):
                        if (value == 0) {
                            instructions.position = jumpIndex;
                        }
                    default: 
                }
            case OpCode.Jump:
                final jumpIndex = instructions.readInt32();

                instructions.position = jumpIndex;
            case OpCode.Call:
                final object = stack.pop();

                callStack.add(new ReturnAddress(instructions.position, object));

                switch (object) {
                    case Object.UserFunction(position):
                        instructions.position = position;
                    case Object.BuiltInFunction(memberFunction):
                        builtInTable.callFunction(memberFunction);
                    default: error.error("object is not a function");
                }
            case OpCode.Return:
                instructions.position = callStack.pop().byteIndex;
                if (stack.isEmpty()) {
                    stack.add(Object.Null);
                }
            case OpCode.Negate:
                final negValue = stack.pop();

                switch (negValue) {
                    case Object.Float(value):
                        stack.add(Object.Float(-value));
                    default: error.error("only floats can be negated");
                }
            case OpCode.Not:
                final invValue = stack.pop();

                switch (invValue) {
                    case Object.Float(value):
                        stack.add(Object.Float(value == 1 ? 0 : 1));
                    default: error.error("only floats can be inverted");
                }
            case OpCode.Pop:
                stack.pop();

            default:

        }
    }
}