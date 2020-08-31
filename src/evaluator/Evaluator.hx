package evaluator;

import object.objects.FunctionObj;
import haxe.Int64;
import object.ObjectType;
import object.objects.IntObject;
import object.objects.Object;
import code.OpCode;
import haxe.io.Bytes;
import haxe.ds.GenericStack;

class Evaluator {

    final stack:GenericStack<Object> = new GenericStack();
    final callStack:GenericStack<Int> = new GenericStack();
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
                if (!stack.isEmpty() && stack.first().type == ObjectType.Int) {
                    trace(cast(stack.first(), IntObject).value);
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
            case OpCode.Add | OpCode.Multiply | OpCode.Equals | OpCode.SmallerThan | OpCode.GreaterThan | OpCode.Subtract | OpCode.Divide | OpCode.Modulo:
                final left = cast(stack.pop(), IntObject);
                final right = cast(stack.pop(), IntObject);

                final result:Int64 = switch (opCode) {
                    case OpCode.Add: left.value + right.value;
                    case OpCode.Multiply: left.value * right.value;
                    case OpCode.Equals: left.value == right.value ? 1 : 0;
                    case OpCode.SmallerThan: left.value > right.value ? 1 : 0;
                    case OpCode.GreaterThan: left.value < right.value ? 1 : 0;
                    case OpCode.Subtract: right.value - left.value;
                    case OpCode.Divide: right.value / left.value;
                    case OpCode.Modulo: right.value % left.value;
                    default: -1; // TODO: Error
                }

                stack.add(new IntObject(result));
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

                if (value == null) {
                    // TODO error
                }

                stack.add(value);
            case OpCode.JumpNot:
                final jumpIndex = readInt32();
                
                final conditionValue = cast(stack.pop(), IntObject);
                if (conditionValue.value == 0) {
                    byteIndex = jumpIndex;
                }
            case OpCode.Jump:
                final jumpIndex = readInt32();

                byteIndex = jumpIndex;
            case OpCode.Call:
                final jumpIndex = cast(stack.pop(), FunctionObj).position;
                callStack.add(byteIndex);

                byteIndex = Int64.toInt(jumpIndex);
            case OpCode.Return:
                if (!callStack.isEmpty()) {
                    byteIndex = callStack.pop();
                }
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