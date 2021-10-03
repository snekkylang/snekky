package std.lib.namespaces.io;

import object.NumberObj;
import object.Object.ObjectType;
import vm.VirtualMachine;

class IoNamespace extends MemberObject {

    public static final name = "Io";

    public function new(vm:VirtualMachine) {
        super(vm);
    }

    override function initMembers() {
        addFunctionMember("Bytes", [ObjectType.Number], function(p) {
            final size = Std.int(cast(p[0], NumberObj).value);
            
            return new Bytes(vm, haxe.io.Bytes.alloc(size)).getMembers();
        });

        addFunctionMember("BytesOutput", [], function(p) {
            return new BytesOutput(vm, new haxe.io.BytesOutput()).getMembers();
        });
    }
}