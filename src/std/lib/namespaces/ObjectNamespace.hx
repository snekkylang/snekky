package std.lib.namespaces;

import evaluator.Evaluator;

class ObjectNamespace extends MemberObject {

    public static final name = "Object";

    public function new(evaluator:Evaluator) {
        super(evaluator);

        addFunctionMember("typeof", 1, function(parameters) {
            return Object.String(parameters[0].getName());
        });
    }
}