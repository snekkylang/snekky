package evaluator;

import object.objects.IntObject;
import object.objects.Object;
import code.OpCode;
import haxe.io.Bytes;

class Evaluator {

    final stack:Array<Object> = [];
    final byteCode:Bytes;
    final constants:Array<Object>;
    var byteIndex = 0;

    public function new(byteCode:Bytes, constants:Array<Object>) {
        this.byteCode = byteCode;
        this.constants = constants;
    }

    public function eval() {
        trace(byteCode.toHex());

        while (byteIndex < byteCode.length) {
            evalInstruction();
        }
    }

    function evalInstruction() {
        final opCode = OpCode.createByIndex(byteCode.get(byteIndex));
        byteIndex++;
        
        switch (opCode) {
            case OpCode.Add | OpCode.Multiply:
                final left = cast(stack.pop(), IntObject);
                final right = cast(stack.pop(), IntObject);

                final result = switch (opCode) {
                    case OpCode.Add: left.value + right.value;
                    case OpCode.Multiply: left.value * right.value;
                    default: -1; // TODO: Error
                }

                stack.push(new IntObject(result));
            case OpCode.Constant:
                final constantIndex = byteCode.getInt32(byteIndex);
                byteIndex += 4;

                stack.push(constants[constantIndex]);
            case OpCode.Pop:
                trace(cast(stack.pop(), IntObject).value);

            default:

        }
    }
}