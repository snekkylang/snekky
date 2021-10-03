package object;

import vm.VirtualMachine;
import object.Object.ObjectType;

class NullObj extends Object {

    public function new(vm:VirtualMachine) {
        super(ObjectType.Null, vm);
    }

    override function initMembers() {
        addFunctionMember("toString", [], function(p) {
            return new StringObj(toString(), vm);
        });
    }

    override function toString():String {
        return "null";
    }

    override function equals(o:Object):Bool {
        return o.type == ObjectType.Null;
    }

    override function clone():Object {
        return new NullObj(vm);
    }
}