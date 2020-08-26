package evaluator;

import object.ObjectType;
import compiler.symbol.SymbolTable;
import object.objects.IntObject;
import object.objects.Object;
import code.OpCode;
import haxe.io.Bytes;

class Evaluator {

    final stack:Array<Object> = [];
    final byteCode:Bytes;
    final constants:Array<Object>;
    final symbolTable:SymbolTable;
    var byteIndex = 0;
    var env = new Environment(null);

    public function new(byteCode:Bytes, constants:Array<Object>, symbolTable:SymbolTable) {
        this.byteCode = byteCode;
        this.constants = constants;
        this.symbolTable = symbolTable;
    }

    public function eval() {
        trace(byteCode.toHex());

        while (byteIndex < byteCode.length) {
            evalInstruction();

            try {
                if (stack.length > 0 && stack[stack.length - 1].type == ObjectType.Int) {
                    trace(cast(stack[stack.length - 1], IntObject).value);
                }
            } catch(e) {
                trace("error");
            }
        }
    }

    function evalInstruction() {
        final opCode = OpCode.createByIndex(byteCode.get(byteIndex));
        byteIndex++;
        
        switch (opCode) {
            case OpCode.Add | OpCode.Multiply | OpCode.Equal | OpCode.SmallerThan | OpCode.GreaterThan:
                final left = cast(stack.pop(), IntObject);
                final right = cast(stack.pop(), IntObject);

                final result = switch (opCode) {
                    case OpCode.Add: left.value + right.value;
                    case OpCode.Multiply: left.value * right.value;
                    case OpCode.Equal: left.value == right.value ? 1 : 0;
                    case OpCode.SmallerThan: left.value > right.value ? 1 : 0;
                    case OpCode.GreaterThan: left.value < right.value ? 1 : 0;
                    default: -1; // TODO: Error
                }

                stack.push(new IntObject(result));
            case OpCode.Constant:
                final constantIndex = readInt32();

                stack.push(constants[constantIndex]);
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

                stack.push(value);
            case OpCode.JumpNot:
                final jumpIndex = readInt32();
                
                final conditionValue = cast(stack.pop(), IntObject);
                if (conditionValue.value == 0) {
                    byteIndex = jumpIndex;
                }
            case OpCode.Jump:
                final jumpIndex = readInt32();

                byteIndex = jumpIndex;
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