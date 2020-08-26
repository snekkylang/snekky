package evaluator;

import object.objects.BooleanObject;
import parser.nodes.Boolean;
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
            case OpCode.SetLocal:
                final localIndex = byteCode.getInt32(byteIndex);
                byteIndex += 4;

                final value = stack.pop();
                env.setVariable(localIndex, value);
            case OpCode.GetLocal:
                final localIndex = byteCode.getInt32(byteIndex);
                byteIndex += 4;

                final value = env.getVariable(localIndex);

                if (value == null) {
                    // TODO error
                }

                stack.push(value);
            case OpCode.JumpNot:
                final jumpIndex = byteCode.getInt32(byteIndex);
                byteIndex += 4;
                
                final conditionValue = cast(stack.pop(), BooleanObject);
                if (!conditionValue.value) {
                    byteIndex = jumpIndex;
                }
            case OpCode.Jump:
                trace("ok");
                final jumpIndex = byteCode.getInt32(byteIndex);
                byteIndex += 4;

                byteIndex = jumpIndex;
            case OpCode.Pop:
                stack.pop();

            default:

        }
    }
}