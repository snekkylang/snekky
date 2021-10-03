package std.lib.namespaces;

import object.NumberObj;
import object.StringObj;
import object.Object;
import vm.VirtualMachine;

class NumberNamespace extends MemberObject {

    public static final name = "Number";

    public function new(vm:VirtualMachine) {
        super(vm);
    }

    override function initMembers() {
        addFunctionMember("parse", [ObjectType.String], function(p) {
            final value = cast(p[0], StringObj).value;
            
            return new NumberObj(Std.parseFloat(value), vm);
        });
    }
}