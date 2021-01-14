package object;

import object.Object.ObjectType;
import vm.VirtualMachine;

class BooleanObj extends Object {

    public final value:Bool;

    public function new(value:Bool, vm:VirtualMachine) {
        super(ObjectType.Boolean, vm);

        this.value = value;

        if (vm == null) {
            return;
        }

        addFunctionMember("toString", [], function(p) {
            return new StringObj(toString(), vm);
        });
    }

    override function toString():String {
        return value ? "true" : "false";
    }

    override function equals(o:Object):Bool {
        if (o.type != ObjectType.Boolean) {
            return false;
        }

        return cast(o, BooleanObj).value == value;
    }

    override function clone():Object {
        return new BooleanObj(value, vm);
    }
}