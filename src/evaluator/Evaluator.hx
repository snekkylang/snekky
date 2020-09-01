package evaluator;

import object.objects.StringObj;
import error.RuntimeError;
import object.objects.FloatObj;
import object.objects.FunctionObj;
import object.ObjectType;
import object.objects.Object;
import code.OpCode;
import haxe.io.Bytes;
import haxe.ds.GenericStack;

class Evaluator {

    final stack:GenericStack<Object> = new GenericStack();
    final callStack:GenericStack<ReturnAddress> = new GenericStack();
    final byteCode:Bytes;
    final constants:Array<Object>;
    var byteIndex = 0;
    var env = new Environment();

    public function new(byteCode:Bytes, constants:Array<Object>) {
        this.byteCode = byteCode;
        this.constants = constants;
    }

    public function eval() {
        //trace(byteCode.toHex());

        while (byteIndex < byteCode.length) {
            evalInstruction();

            try {
                if (!stack.isEmpty() && stack.first().type == ObjectType.Float) {
                    trace(cast(stack.first(), FloatObj).value);
                }
            } catch(e) {
                trace(e);
            }
        }
    }

    function evalInstruction() {
        final opCode = OpCode.createByIndex(byteCode.get(byteIndex));
        byteIndex++;
        
        switch (opCode) {
            case OpCode.Equals:
                final left = stack.pop();
                final right = stack.pop();

                if (left.type != right.type) {
                    stack.add(new FloatObj(0));
                    return;
                }

                switch (left.type) {
                    case ObjectType.Float:
                        final cLeft = cast(left, FloatObj).value;
                        final cRight = cast(right, FloatObj).value;
                        stack.add(new FloatObj(cLeft == cRight ? 1 : 0));
                    case ObjectType.String:
                        final cLeft = cast(left, StringObj).value;
                        final cRight = cast(right, StringObj).value;
                        stack.add(new FloatObj(cLeft == cRight ? 1 : 0));
                    default:
                }
            case OpCode.Add | OpCode.Multiply | OpCode.SmallerThan | OpCode.GreaterThan | OpCode.Subtract | OpCode.Divide | OpCode.Modulo:
                final right = stack.pop();
                final left = stack.pop();

                if (left.type != ObjectType.Float || right.type != ObjectType.Float) {
                    RuntimeError.error('cannot perform operation $opCode on left (${left.type}) and right (${right.type}) value', callStack);
                }

                final cRight = cast(right, FloatObj).value;
                final cLeft = cast(left, FloatObj).value;

                final result:Float = switch (opCode) {
                    case OpCode.Add: cLeft + cRight;
                    case OpCode.Multiply: cLeft * cRight;
                    case OpCode.Equals: cLeft == cRight ? 1 : 0;
                    case OpCode.SmallerThan: cRight > cLeft ? 1 : 0;
                    case OpCode.GreaterThan: cRight < cLeft ? 1 : 0;
                    case OpCode.Subtract: cLeft - cRight;
                    case OpCode.Divide: cLeft / cRight;
                    case OpCode.Modulo: cLeft % cRight;
                    default: -1;
                }

                stack.add(new FloatObj(result));
            case OpCode.Constant:
                final constantIndex = readInt32();

                stack.add(constants[constantIndex]);
            case OpCode.SetLocal:
                final localIndex = readInt32();

                final value = stack.pop();
                env.setVariable(localIndex, value);
            case OpCode.GetLocal:
                final localIndex = readInt32();

                final value = env.getVariable(localIndex);
                stack.add(value);
            case OpCode.JumpNot:
                final jumpIndex = readInt32();
                
                final conditionValue = cast(stack.pop(), FloatObj);
                if (conditionValue.value == 0) {
                    byteIndex = jumpIndex;
                }
            case OpCode.Jump:
                final jumpIndex = readInt32();

                byteIndex = jumpIndex;
            case OpCode.Call:
                final calledFunction = cast(stack.pop(), FunctionObj);
                callStack.add(new ReturnAddress(byteIndex, calledFunction));

                byteIndex = calledFunction.bytePosition;
            case OpCode.Return:
                if (!callStack.isEmpty()) {
                    byteIndex = callStack.pop().returnAddress;
                }
            case OpCode.Negate:
                final negValue = cast(stack.pop(), FloatObj).value;
                stack.add(new FloatObj(-negValue));
            case OpCode.Invert:
                final invValue = cast(stack.pop(), FloatObj).value;
                stack.add(new FloatObj(invValue == 1 ? 0 : 1));
            case OpCode.Pop:
                stack.pop();

            default:

        }
    }

    function readInt32():Int {
        final value = byteCode.getInt32(byteIndex);
        byteIndex += 4;
        return value;
    }
}