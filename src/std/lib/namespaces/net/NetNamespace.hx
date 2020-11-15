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

            try {
                final host = cast(options.value.get("host"), StringObj).value;
                final port = Std.int(cast(options.value.get("port"), NumberObj).value);
                final secure = cast(options.value.get("secure"), BooleanObj).value;
    
                return new Socket(evaluator, host, port, secure).getMembers();
            } catch (e) {
                error("missing option keys");
                return null;
            }
        });
    }
}