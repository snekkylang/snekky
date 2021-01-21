package vm;

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

class VirtualMachine {

    public final stack:GenericStack<Object> = new GenericStack();
    public var frames:GenericStack<Frame> = new GenericStack();
    public var currentFrame:Frame;
    public var constantPool:Array<Object>;
    public var instructions:BytesInput;
    public var filenameTable:FilenameTable;
    public var lineNumberTable:LineNumberTable;
    public var variableTable:VariableTable;
    final builtInTable:BuiltInTable;
    public final error:RuntimeError;
    public final fileData:Bytes;
    #if target.sys
    final threadLocks:Array<sys.thread.Lock> = [];
    #end

    public function new(fileData:Bytes) {
        this.fileData = fileData;

        newWithState(fileData);
        builtInTable = new BuiltInTable(this);

        error = new RuntimeError(this);
        pushFrame(null, 0, null);
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

    public function pushFrame(context:Frame, returnAddress:Int, calledFunction:Function) {
        frames.add(new Frame(context, returnAddress, calledFunction));
        currentFrame = frames.first();
    }

    public function popFrame():Frame {
        final frame = frames.pop();
        currentFrame = frames.first();

        return frame;
    }

    public function callFunction(closure:ClosureObj, parameters:Array<Object>):Object {
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
                pushFrame(closure.context, instructions.length, cUserFunction);
                instructions.position = cUserFunction.position;
                eval();
                instructions.position = oPosition;
            case ObjectType.BuiltInFunction:
                final cBuiltInFunction = cast(closure.func, BuiltInFunctionObj);

                builtInTable.callFunction(cBuiltInFunction);
            default:
        }

        return stack.pop();
    }

    #if target.sys
    public function addThreadLock(lock:sys.thread.Lock) {
        threadLocks.push(lock);
    }
    #end

    public function eval() {
        while (instructions.position < instructions.length) {
            evalInstruction();
        }

        #if target.sys
        for (lock in threadLocks) {
            lock.wait();
        }
        #end
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
                    default: error.error("index operator cannot be used on this datatype");      
                }
            case OpCode.ConcatString:
                final right = stack.pop().toString();
                final left = stack.pop().toString();

                stack.add(new StringObj('$left$right', this));
            case OpCode.Add | OpCode.Multiply | OpCode.LessThan | OpCode.GreaterThan | OpCode.Subtract 
                | OpCode.Divide | OpCode.Modulo | OpCode.BitAnd | OpCode.BitOr | OpCode.BitShiftLeft
                | OpCode.BitShiftRight | OpCode.BitXor:
                final right = stack.pop();
                final left = stack.pop();

                if (left.type != ObjectType.Number || right.type != ObjectType.Number) {
                    error.error('cannot perform operation (left: ${left.type}, right: ${right.type})');  
                }

                final cLeft = cast(left, NumberObj).value;
                final cRight = cast(right, NumberObj).value;

                final o = switch (opCode) {
                    case OpCode.Add: new NumberObj(cLeft + cRight, this);
                    case OpCode.Subtract: new NumberObj(cLeft - cRight, this);
                    case OpCode.Multiply: new NumberObj(cLeft * cRight, this);
                    case OpCode.Divide: new NumberObj(cLeft / cRight, this);
                    case OpCode.Modulo: new NumberObj(cLeft % cRight, this);
                    case OpCode.LessThan: new BooleanObj(cLeft < cRight, this);
                    case OpCode.GreaterThan: new BooleanObj(cLeft > cRight, this);
                    case OpCode.BitAnd: new NumberObj(Std.int(cLeft) & Std.int(cRight), this);
                    case OpCode.BitOr: new NumberObj(Std.int(cLeft) | Std.int(cRight), this);
                    case OpCode.BitShiftLeft: new NumberObj(Std.int(cLeft) << Std.int(cRight), this);
                    case OpCode.BitShiftRight: new NumberObj(Std.int(cLeft) >> Std.int(cRight), this);
                    case OpCode.BitXor: new NumberObj(Std.int(cLeft) ^ Std.int(cRight), this);
                    default: new NullObj(this);
                };

                stack.add(o);
            case OpCode.Equals:
                final right = stack.pop();
                final left = stack.pop();
                
                final equals = left.equals(right);

                stack.add(new BooleanObj(equals, this));
            case OpCode.Constant:
                final constantIndex = instructions.readInt32();

                final constant = switch (constantPool[constantIndex].type) {
                    case ObjectType.UserFunction: new ClosureObj(cast(constantPool[constantIndex], UserFunctionObj), currentFrame, this);
                    default: constantPool[constantIndex];
                }

                stack.add(constant);
            case OpCode.Store:
                final localIndex = instructions.readInt32();

                final value = stack.pop();
                currentFrame.setVariable(localIndex, value);
            case OpCode.Load:
                final localIndex = instructions.readInt32();
                final value = currentFrame.getVariable(localIndex);

                stack.add(value);
            case OpCode.LoadBuiltIn:
                final builtInIndex = instructions.readInt32();

                stack.add(builtInTable.resolveIndex(builtInIndex));
            case OpCode.JumpNot:
                final jumpIndex = instructions.readInt32();
                try {
                    final conditionValue = cast(stack.pop(), BooleanObj).value;

                    if (!conditionValue) {
                        instructions.position = jumpIndex;
                    }
                } catch (e) {
                    error.error("expected condition to evaluate to boolean");
                }
            case OpCode.JumpPeek:
                final jumpIndex = instructions.readInt32();
                try {
                    final conditionValue = cast(stack.first(), BooleanObj).value;

                    if (conditionValue) {
                        instructions.position = jumpIndex;
                    }
                } catch (e) {
                    error.error("expected condition to evaluate to boolean");
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
                        pushFrame(cClosure.context, instructions.position, cClosure.func);

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
                instructions.position = popFrame().returnAddress;
                if (stack.isEmpty()) {
                    stack.add(new NullObj(this));
                }
            case OpCode.Negate:
                final negValue = stack.pop();

                if (negValue.type == ObjectType.Number) {
                    final value = cast(negValue, NumberObj).value;
                    stack.add(new NumberObj(-value, this));      
                } else {
                    error.error("only numbers can be negated");   
                }
            case OpCode.BitNot:
                final notValue = stack.pop();

                if (notValue.type == ObjectType.Number) {
                    final value = cast(notValue, NumberObj).value;
                    stack.add(new NumberObj(~Std.int(value), this));
                } else {
                    error.error("cannot perform operation");
                }
            case OpCode.Not:
                final invValue = stack.pop();

                if (invValue.type == ObjectType.Boolean) {
                    final value = cast(invValue, BooleanObj).value;
                    stack.add(new BooleanObj(!value, this));      
                } else {
                    error.error("only booleans can be inverted");   
                }
            case OpCode.Pop:
                stack.pop();

            default:

        }
    }
}