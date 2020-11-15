package std.lib.namespaces.net;

import object.BooleanObj;
import object.NumberObj;
import object.StringObj;
import object.HashObj;
import object.Object.ObjectType;
import evaluator.Evaluator;

class NetNamespace extends MemberObject {

    public static final name = "Net";

    public function new(evaluator:Evaluator) {
        super(evaluator);

        addFunctionMember("Socket", 1, function(p) {
            assertParameterType(p[0], ObjectType.Hash);
            final options = cast(p[0], HashObj);

            var host = "localhost";
            var port = 21;
            var secure = false;
            try {
                host = cast(options.value.get("host"), StringObj).value;
                port = Std.int(cast(options.value.get("port"), NumberObj).value);
                secure = cast(options.value.get("secure"), BooleanObj).value;
            } catch (e) {
                error("missing option keys");
            }

            try {
                return new Socket(evaluator, host, port, secure).getMembers();
            } catch (e) {
                error("failed to open socket");
                return null;
            }
        });
    }
}