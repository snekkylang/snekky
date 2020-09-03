package evaluator;

import compiler.debug.LocalVariableTable;
import error.RuntimeError;
import compiler.debug.LineNumberTable;
import evaluator.builtin.BuiltInTable;
import object.ObjectOrigin;
import object.objects.StringObj;
import object.objects.FloatObj;
import object.objects.FunctionObj;
import object.ObjectType;
import object.objects.Object;
import code.OpCode;
import haxe.io.Bytes;
import haxe.ds.GenericStack;

class Evaluator {

    public final stack:GenericStack<Object> = new GenericStack();
    public final callStack:GenericStack<ReturnAddress> = new GenericStack();
    final byteCode:Bytes;
    final constants:Array<Object>;
    final lineNumberTable:LineNumberTable;
    final localVariableTable:LocalVariableTable;
    final builtInTable:BuiltInTable;
    var byteIndex = 0;
    final env = new Environment();
    public final error:RuntimeError;

    public function new(byteCode:Bytes, constants:Array<Object>, lineNumberTable:LineNumberTable, localVariableTable:LocalVariableTable) {
        this.byteCode = byteCode;
        this.constants = constants;
        this.lineNumberTable = lineNumberTable;
        this.localVariableTable = localVariableTable;

        builtInTable = new BuiltInTable(this);
        error = new RuntimeError(callStack, this.lineNumberTable, this.localVariableTable);
    }

    public function eval() {
        while (byteIndex < byteCode.length) {
            evalInstruction();
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
                    error.error('cannot perform operation $opCode on left (${left.type}) and right (${right.type}) value');
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

                if (value == null) {
                    error.error("failed to evaluate expression");
                }

                env.setVariable(localIndex, value);
            case OpCode.GetLocal:
                final localIndex = readInt32();

                final value = env.getVariable(localIndex);

                if (value == null) {
                    error.error("value of symbol undefined");
                }

                stack.add(value);
            case OpCode.GetBuiltIn:
                final builtInIndex = readInt32();

                stack.add(new FunctionObj(builtInIndex, ObjectOrigin.BuiltIn));
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

                if (calledFunction.origin == ObjectOrigin.UserDefined) {
                    byteIndex = calledFunction.index;
                } else {
                    builtInTable.execute(calledFunction.index);
                }
            case OpCode.Return:
                byteIndex = callStack.pop().byteIndex;
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