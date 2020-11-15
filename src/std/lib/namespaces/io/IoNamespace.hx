package std.lib.namespaces.io;

import object.NumberObj;
import object.Object.ObjectType;
import evaluator.Evaluator;

class IoNamespace extends MemberObject {

    public static final name = "Io";

    public function new(evaluator:Evaluator) {
        super(evaluator);

        addFunctionMember("Bytes", 1, function(p) {
            assertParameterType(p[0], ObjectType.Number);
            final size = Std.int(cast(p[0], NumberObj).value);
            
            return new Bytes(evaluator, haxe.io.Bytes.alloc(size)).getMembers();
        });

        addFunctionMember("BytesOutput", 0, function(p) {
            return new BytesOutput(evaluator, new haxe.io.BytesOutput()).getMembers();
        });
    }
}