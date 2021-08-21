package object;

import vm.VirtualMachine;
import object.Object.ObjectType;
import vm.Frame;

class ClosureObj extends Object {

    public final func:Function;
    public var context:Frame;

    public function new(func:Function, context:Frame, vm:VirtualMachine) {
        super(ObjectType.Closure, vm);

        this.func = func;
        this.context = context;
    }

    public function call(arguments:Array<Object>):Object {
        arguments.reverse();

        for (a in arguments) {
            vm.stack.add(a);
        }

        switch (func.type) {
            case ObjectType.UserFunction:
                final cUserFunction = cast(func, UserFunctionObj);

                if (arguments.length != cUserFunction.parametersCount) {
                    error("wrong number of arguments to function");
                }
                final oPosition = vm.instructions.position;
                vm.pushFrame(context, vm.instructions.length, cUserFunction);
                vm.instructions.position = cUserFunction.position;
                while (vm.instructions.position < vm.instructions.length) {
                    vm.evalInstruction();
                }
                vm.instructions.position = oPosition;
            case ObjectType.BuiltInFunction:
                final cBuiltInFunction = cast(func, BuiltInFunctionObj);

                vm.builtInTable.callFunction(cBuiltInFunction);
            default:
        }

        return vm.popStack();   
    }

    override function getMembers():HashObj {
        return func.getMembers();
    }

    override function toString():String {
        return '#closure(${func.toString()})';
    }

    override function equals(o:Object):Bool {
        if (o.type != ObjectType.Closure) {
            return false;
        }

        return cast(o, ClosureObj).func == func;
    }

    override function clone():Object {
        return new ClosureObj(func, context, vm);
    }
}