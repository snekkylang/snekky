package evaluator;

import object.ObjectType;
import compiler.symbol.SymbolTable;
import object.objects.IntObject;
import object.objects.Object;
import code.OpCode;
import haxe.io.Bytes;
import haxe.ds.GenericStack;

class Evaluator {

    final stack:GenericStack<Object> = new GenericStack();
    final byteCode:Bytes;
    final constants:Array<Object>;
    final symbolTable:SymbolTable;
    var byteIndex = 0;
    var env = new Environment();

    public function new(byteCode:Bytes, constants:Array<Object>, symbolTable:SymbolTable) {
        this.byteCode = byteCode;
        this.constants = constants;
        this.symbolTable = symbolTable;
    }

    public function eval() {
        //trace(byteCode.toHex());

        while (byteIndex < byteCode.length) {
            evalInstruction();

            /* try {
                if (!stack.isEmpty() && stack.first().type == ObjectType.Int) {
                    trace(cast(stack.first(), IntObject).value);

                    if (cast(stack.first(), IntObject).value == 1969) {
                        Sys.exit(1);
                    }
                }
            } catch(e) {
                trace(e);
            } */
        }
    }

    function evalInstruction() {
        final opCode = OpCode.createByIndex(byteCode.get(byteIndex));
        byteIndex++;
        
        switch (opCode) {
            case OpCode.Add | OpCode.Multiply | OpCode.Equal | OpCode.SmallerThan | OpCode.GreaterThan | OpCode.Minus | OpCode.Divide | OpCode.Modulo:
                final left = cast(stack.pop(), IntObject);
                final right = cast(stack.pop(), IntObject);

                final result = switch (opCode) {
                    case OpCode.Add: left.value + right.value;
                    case OpCode.Multiply: left.value * right.value;
                    case OpCode.Equal: left.value == right.value ? 1 : 0;
                    case OpCode.SmallerThan: left.value > right.value ? 1 : 0;
                    case OpCode.GreaterThan: left.value < right.value ? 1 : 0;
                    case OpCode.Minus: right.value - left.value;
                    case OpCode.Divide: Std.int(right.value / left.value);
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