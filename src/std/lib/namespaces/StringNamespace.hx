package std.lib.namespaces;

import object.Object;
import evaluator.Evaluator;

class StringNamespace extends MemberObject {

    public static final name = "String";

    public function new(evaluator:Evaluator) {
        super(evaluator);

        addFunctionMember("parseNumber", 1, function(parameters) {
            return switch (parameters[0]) {
                case Object.String(value): Object.Float(Std.parseFloat(value));
                default: Object.Null;
            }
        });
    }
}