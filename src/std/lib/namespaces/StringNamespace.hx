package std.lib.namespaces;

import object.NumberObj;
import object.Object.ObjectType;
import object.StringObj;
import vm.VirtualMachine;

class StringNamespace extends MemberObject {

    public static final name = "String";

    public function new(vm:VirtualMachine) {
        super(vm);

        addFunctionMember("fromCharCode", [ObjectType.Number], function(p) {
            final value = Std.int(cast(p[0], NumberObj).value);
            
            return new StringObj(std.String.fromCharCode(value), vm);
        });
    }
}