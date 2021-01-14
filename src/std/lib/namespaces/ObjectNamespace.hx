package std.lib.namespaces;

import object.StringObj;
import vm.VirtualMachine;

class ObjectNamespace extends MemberObject {

    public static final name = "Object";

    public function new(vm:VirtualMachine) {
        super(vm);

        addFunctionMember("typeof", [null], function(parameters) {
            return new StringObj(Std.string(parameters[0].type), vm);
        });
    }
}