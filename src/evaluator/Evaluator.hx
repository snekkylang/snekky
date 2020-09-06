package evaluator;

import object.ObjectWrapper;
import object.objects.ArrayObj;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
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
import haxe.ds.GenericStack;

class Evaluator {

    public final stack:GenericStack<ObjectWrapper> = new GenericStack();
    public final callStack:GenericStack<ReturnAddress> = new GenericStack();
    final byteCode:BytesInput;
    final constants:Array<Object>;
    final lineNumberTable:LineNumberTable;
    final localVariableTable:LocalVariableTable;
    final builtInTable:BuiltInTable;
    final env = new Environment();
    public final error:RuntimeError;

    public function new(byteCode:BytesOutput, constants:Array<Object>, lineNumberTable:LineNumberTable, localVariableTable:LocalVariableTable) {
        this.byteCode = new BytesInput(byteCode.getBytes());
        this.constants = constants;
        this.lineNumberTable = lineNumberTable;
        this.localVariableTable = localVariableTable;

        builtInTable = new BuiltInTable(this);
        error = new RuntimeError(callStack, this.lineNumberTable, this.localVariableTable, this.byteCode);
    }

    public function eval() {
        while (byteCode.position < byteCode.length) {
            evalInstruction();
        }
    }

    function evalInstruction() {
        final opCode = byteCode.readByte();
        
        switch (opCode) {
            case OpCode.Array:
                final arrayLength = byteCode.readInt32();
                final arrayObj = new ArrayObj();

                for (i in 0...arrayLength) {
                    arrayObj.unshift(stack.pop());
                }

                stack.add(new ObjectWrapper(arrayObj));
            case OpCode.Index:
                try {
                    final index = Std.int(cast(stack.pop().object, FloatObj).value);
                    final target = cast(stack.pop().object, ArrayObj);

                    stack.add(target.values[index]);
                } catch (err) {
                    error.error("index operator cannot be used on this datatype");
                }
            case OpCode.Assign:
                final right = stack.pop();
                final left = stack.pop();

                left.object = right.object;
            case OpCode.ConcatString:
                final right = stack.pop().object;
                final left = stack.pop().object;
                
                stack.add(new ObjectWrapper(new StringObj('${left.toString()}${right.toString()}')));
            case OpCode.Equals:
                final right = stack.pop().object;
                final left = stack.pop().object;

                if (left.type != right.type) {
                    stack.add(new ObjectWrapper(new FloatObj(0)));
                    return;
                }

                switch (left.type) {
                    case ObjectType.Float:
                        final cLeft = cast(left, FloatObj).value;
                        final cRight = cast(right, FloatObj).value;
                        stack.add(new ObjectWrapper(new FloatObj(cLeft == cRight ? 1 : 0)));
                    case ObjectType.String:
                        final cLeft = cast(left, StringObj).value;
                        final cRight = cast(right, StringObj).value;
                        stack.add(new ObjectWrapper(new FloatObj(cLeft == cRight ? 1 : 0)));
                    default:
                }
            case OpCode.Add | OpCode.Multiply | OpCode.SmallerThan | OpCode.GreaterThan | OpCode.Subtract | OpCode.Divide | OpCode.Modulo:
                final right = stack.pop().object;
                final left = stack.pop().object;

                var cRight;
                var cLeft;

                try {
                    cRight = cast(right, FloatObj).value;
                    cLeft = cast(left, FloatObj).value;
                } catch(e) {
                    error.error('cannot perform operation $opCode on left (${left.type}) and right (${right.type}) value');
                    return; 
                }

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

                stack.add(new ObjectWrapper(new FloatObj(result)));
            case OpCode.Constant:
                final constantIndex = byteCode.readInt32();

                stack.add(new ObjectWrapper(constants[constantIndex]));
            case OpCode.SetLocal:
                final localIndex = byteCode.readInt32();

                final value = stack.pop();

                if (value == null) {
                    error.error("failed to evaluate expression");
                }

                env.setVariable(localIndex, value);
            case OpCode.GetLocal:
                final localIndex = byteCode.readInt32();

                final value = env.getVariable(localIndex);

                if (value == null) {
                    error.error("value of symbol undefined");
                }

                stack.add(value);
            case OpCode.GetBuiltIn:
                final builtInIndex = byteCode.readInt32();

                stack.add(new ObjectWrapper(new FunctionObj(builtInIndex, ObjectOrigin.BuiltIn)));
            case OpCode.JumpNot:
                final jumpIndex = byteCode.readInt32();
                
                final conditionValue = cast(stack.pop().object, FloatObj);
                if (conditionValue.value == 0) {
                    byteCode.position = jumpIndex;
                }
            case OpCode.Jump:
                final jumpIndex = byteCode.readInt32();

                byteCode.position = jumpIndex;
            case OpCode.Call:
                final calledFunction = cast(stack.pop().object, FunctionObj);
                callStack.add(new ReturnAddress(byteCode.position, calledFunction));

                if (calledFunction.origin == ObjectOrigin.UserDefined) {
                    byteCode.position = calledFunction.index;
                } else {
                    builtInTable.execute(calledFunction.index);
                }
            case OpCode.Return:
                byteCode.position = callStack.pop().byteIndex;
            case OpCode.Negate:
                final negValue = cast(stack.pop().object, FloatObj).value;
                stack.add(new ObjectWrapper(new FloatObj(-negValue)));
            case OpCode.Invert:
                final invValue = cast(stack.pop(), FloatObj).value;
                stack.add(new ObjectWrapper(new FloatObj(invValue == 1 ? 0 : 1)));
            case OpCode.Pop:
                stack.pop();

            default:

        }
    }
}