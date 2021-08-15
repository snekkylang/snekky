package object;

import vm.VirtualMachine;
import object.Object.ObjectType;

class UserFunctionObj extends Function {

    public final position:Int;

    public function new(position:Int, parametersCount:Int, vm:VirtualMachine) {
        super(ObjectType.UserFunction, parametersCount, vm);

        this.position = position;

        if (vm == null) {
            return;
        }

        addFunctionMember("toString", [], function(p) {
            return new StringObj(toString(), vm);
        });
    }

    override function toString():String {
        return '#func(UserDefined)';
    }

    override function equals(o:Object):Bool {
        if (o.type != ObjectType.UserFunction) {
            return false;
        }

        return cast(o, UserFunctionObj).position == position;
    }
}