package std.lib.namespaces.json;

import object.StringObj;
import object.Object.ObjectType;
import object.NullObj;
import vm.VirtualMachine;

class JsonNamespace extends MemberObject {

    public static final name = "Json";

    public function new(vm:VirtualMachine) {
        super(vm);

        addFunctionMember("encode", [null], function(p) {
            return try {
                new StringObj(JsonEncoder.encode(p[0]), vm);
            } catch (e) {
                error(e.message);
                null;
            }
        });

        addFunctionMember("decode", [ObjectType.String], function(p) {
            final json = cast(p[0], StringObj).value;

            return try {
                final decoder = new JsonDecoder(json, vm);
                decoder.decode();
            } catch (e) {
                error(e.message);
                null;
            }
        });
    }
}