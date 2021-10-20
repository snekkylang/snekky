package vm;

#if target.sys
import event.EventLoop;
#end
import object.*;
import haxe.zip.Uncompress;
import compiler.debug.FileNameTable;
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
    #if target.sys
    public final eventLoop = new EventLoop();
    #end
    public var currentFrame:Frame;
    public var constantPool:Array<Object>;
    public var instructions:BytesInput;
    public var fileNameTable:FileNameTable;
    public var lineNumberTable:LineNumberTable;
    public var variableTable:VariableTable;
    public final builtInTable:BuiltInTable;
    public final error:RuntimeError;
    public final fileData:Bytes;

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
        fileNameTable = new FileNameTable().fromByteCode(byteCode);
        lineNumberTable = new LineNumberTable().fromByteCode(byteCode);
        variableTable = new VariableTable().fromByteCode(byteCode);
        constantPool = ConstantPool.fromByteCode(byteCode, this);
        final oPosition = instructions != null ? instructions.position : 0;
        instructions = new BytesInput(byteCode.read(byteCode.readInt32()));
        if (oPosition != -1) {
            instructions.position = oPosition;
        }
    }

    public inline function pushFrame(context:Frame, returnAddress:Int, calledFunction:Function) {
        final expectedStackSize = if (calledFunction != null) {
            Lambda.count(stack) + 1 - calledFunction.parametersCount;
        } else {
            0;
        }

        frames.add(new Frame(context, returnAddress, calledFunction, expectedStackSize));
        currentFrame = frames.first();
    }

    public inline function popFrame():Frame {
        final frame = frames.pop();
        currentFrame = frames.first();

        return frame;
    }

    public inline function popStack():Object {
        final o = stack.pop();
        if (o == null) {
            error.error("failed to evaluate expression");
        }
        return o;
    }

    public function eval() {
        while (instructions.position < instructions.length) {
            evalInstruction();
        }

        #if target.sys
        eventLoop.start();
        #end
    }

    public function evalInstruction() {
        final opCode = instructions.readByte();
        
        switch (opCode) {
            case OpCode.Array:
                final arrayLength = instructions.readInt32();
                final arrayValues:Array<Object> = [];

                for (_ in 0...arrayLength) {
                    arrayValues.push(popStack());
                }

                stack.add(new ArrayObj(arrayValues, this));
            case OpCode.Hash:
                final hashLength = instructions.readInt32();
                final hashValues:StringMap<Object> = new StringMap();

                for (_ in 0...hashLength) {
                    final value = popStack();
                    final key = popStack();

                    if (key.type == ObjectType.String) {
                        hashValues.set(cast(key, StringObj).value, value);
                    } else {
                        error.error("hash key must be a string");   
                    }
                }

                stack.add(new HashObj(hashValues, this));
            case OpCode.LoadIndex:
                final index = popStack();
                final target = popStack();

                final value = switch [target.type, index.type] {
                    case [ObjectType.Array, ObjectType.Number]:
                        final cTarget = cast(target, ArrayObj);
                        final cIndex = cast(index, NumberObj);

                        cTarget.get(Std.int(cIndex.value));
                    case [ObjectType.Hash, ObjectType.String]:
                        final cTarget = cast(target, HashObj);
                        final cIndex = cast(index, StringObj);

                        if (cTarget.exists(cIndex.value)) {
                            cTarget.get(cIndex.value);
                        } else {
                            cTarget.getMembers().get(cIndex.value);
                        }
                    case [_, ObjectType.String]:
                        final cIndex = cast(index, StringObj);

                        target.getMembers().get(cIndex.value);
                    default: new NullObj(this);
                }

                stack.add(value);
            case OpCode.StoreIndex:
                final value = popStack();
                final index = popStack();
                final target = popStack();

                switch [target.type, index.type] {
                    case [ObjectType.Array, ObjectType.Number]:
                        final cTarget = cast(target, ArrayObj);
                        final cIndex = cast(index, NumberObj);

                        cTarget.set(Std.int(cIndex.value), value);
                    case [ObjectType.Hash, ObjectType.String]:
                        final cTarget = cast(target, HashObj);
                        final cIndex = cast(index, StringObj);

                        cTarget.set(cIndex.value, value);
                    case [_, ObjectType.String]:
                        final cIndex = cast(index, StringObj);
    
                        target.getMembers().set(cIndex.value, value);
                    default: error.error("index operator cannot be used on this datatype");      
                }
            case OpCode.ConcatString:
                final right = popStack().toString();
                final left = popStack().toString();

                stack.add(new StringObj('$left$right', this));
            case OpCode.Add | OpCode.Multiply | OpCode.LessThan | OpCode.GreaterThan | OpCode.Subtract 
                | OpCode.Divide | OpCode.Modulo | OpCode.BitAnd | OpCode.BitOr | OpCode.BitShiftLeft
                | OpCode.BitShiftRight | OpCode.BitXor | OpCode.LessThanOrEqual | OpCode.GreaterThanOrEqual:
                final right = popStack();
                final left = popStack();

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
                    case OpCode.LessThanOrEqual: new BooleanObj(cLeft <= cRight, this);
                    case OpCode.GreaterThan: new BooleanObj(cLeft > cRight, this);
                    case OpCode.GreaterThanOrEqual: new BooleanObj(cLeft >= cRight, this);
                    case OpCode.BitAnd: new NumberObj(Std.int(cLeft) & Std.int(cRight), this);
                    case OpCode.BitOr: new NumberObj(Std.int(cLeft) | Std.int(cRight), this);
                    case OpCode.BitShiftLeft: new NumberObj(Std.int(cLeft) << Std.int(cRight), this);
                    case OpCode.BitShiftRight: new NumberObj(Std.int(cLeft) >> Std.int(cRight), this);
                    case OpCode.BitXor: new NumberObj(Std.int(cLeft) ^ Std.int(cRight), this);
                    default: new NullObj(this);
                };

                stack.add(o);
            case OpCode.Equals:
                final right = popStack();
                final left = popStack();
                
                final equals = left.equals(right);

                stack.add(new BooleanObj(equals, this));
            case OpCode.NotEquals:
                final right = popStack();
                final left = popStack();
                
                final equals = !left.equals(right);

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

                final value = popStack();
                currentFrame.setVariable(localIndex, value);
            case OpCode.Load:
                final localIndex = instructions.readInt32();
                final value = currentFrame.getVariable(localIndex);

                stack.add(value);
            case OpCode.LoadBuiltIn:
                final builtInIndex = instructions.readInt32();

                stack.add(builtInTable.resolveIndex(builtInIndex));
            case OpCode.JumpFalse:
                final jumpIndex = instructions.readInt32();
                try {
                    final conditionValue = cast(popStack(), BooleanObj).value;

                    if (!conditionValue) {
                        instructions.position = jumpIndex;
                    }
                } catch (e) {
                    error.error("expected condition to evaluate to boolean");
                }
            case OpCode.JumpTrue:
                final jumpIndex = instructions.readInt32();
                try {
                    final conditionValue = cast(popStack(), BooleanObj).value;

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
                final object = popStack();

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
                final frame = popFrame();
                instructions.position = frame.returnAddress;
                if (frame.expectedStackSize > Lambda.count(stack)) {
                    stack.add(new NullObj(this));
                }
            case OpCode.Negate:
                final negValue = popStack();

                if (negValue.type == ObjectType.Number) {
                    final value = cast(negValue, NumberObj).value;
                    stack.add(new NumberObj(-value, this));      
                } else {
                    error.error("only numbers can be negated");   
                }
            case OpCode.BitNot:
                final notValue = popStack();

                if (notValue.type == ObjectType.Number) {
                    final value = cast(notValue, NumberObj).value;
                    stack.add(new NumberObj(~Std.int(value), this));
                } else {
                    error.error("cannot perform operation");
                }
            case OpCode.Not:
                final invValue = popStack();

                if (invValue.type == ObjectType.Boolean) {
                    final value = cast(invValue, BooleanObj).value;
                    stack.add(new BooleanObj(!value, this));      
                } else {
                    error.error("only booleans can be inverted");   
                }
            case OpCode.Pop:
                popStack();
        }
    }
}