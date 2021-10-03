package std.lib.namespaces.net;

import object.BooleanObj;
import object.Object.ObjectType;
import vm.VirtualMachine;

class NetNamespace extends MemberObject {

    public static final name = "Net";

    public function new(vm:VirtualMachine) {
        super(vm);
    }

    override function initMembers() {
        addFunctionMember("Socket", [ObjectType.Boolean], function(p) {
            final secure = cast(p[0], BooleanObj).value;

            final socket = secure ? new sys.ssl.Socket() : new sys.net.Socket();

            try {
                return new Socket(vm, socket).getMembers();
            } catch (e) {
                error("failed to open socket");
                return null;
            }
        });
    }
}