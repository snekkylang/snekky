package object;

import vm.VirtualMachine;
import object.Object.ObjectType;

class NumberObj extends Object {

    public final value:Float;

    public function new(value:Float, vm:VirtualMachine) {
        super(ObjectType.Number, vm);

        this.value = value;

        if (vm == null) {
            return;
        }

        addFunctionMember("toString", [], function(p) {
            return new StringObj(toString(), vm);
        });
    }

    override function toString():String {
        return Std.string(value);
    }

    override function equals(o:Object):Bool {
        if (o.type != ObjectType.Number) {
            return false;
        }

        return cast(o, NumberObj).value == value;
    }

    override function clone():Object {
        return new NumberObj(value, vm);
    }
}