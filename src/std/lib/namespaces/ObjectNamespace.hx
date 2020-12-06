package std.lib.namespaces;

import object.StringObj;
import evaluator.Evaluator;

class ObjectNamespace extends MemberObject {

    public static final name = "Object";

    public function new(evaluator:Evaluator) {
        super(evaluator);

        addFunctionMember("typeof", [null], function(parameters) {
            return new StringObj(Std.string(parameters[0].type), evaluator);
        });
    }
}