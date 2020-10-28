package std.lib.namespaces;

import object.NumberObj;
import object.StringObj;
import object.Object;
import evaluator.Evaluator;

class NumberNamespace extends MemberObject {

    public static final name = "Number";

    public function new(evaluator:Evaluator) {
        super(evaluator);

        addFunctionMember("parse", 1, function(p) {
            assertParameterType(p[0], ObjectType.String);
            final value = cast(p[0], StringObj).value;
            return new NumberObj(Std.parseFloat(value), evaluator);
        });
    }
}