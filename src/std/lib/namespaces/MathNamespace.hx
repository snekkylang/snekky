package std.lib.namespaces;

import object.NumberObj;
import object.Object;
import evaluator.Evaluator;

class MathNamespace extends MemberObject {

    public static final name = "Math";

    public function new(evaluator:Evaluator) {
        super(evaluator);

        addObjectMember("PI", new NumberObj(Math.PI, evaluator));

        addFunctionMember("abs", [ObjectType.Number], function(p) {
            final value = cast(p[0], NumberObj).value;

            return new NumberObj(Math.abs(value), evaluator);
        });

        addFunctionMember("floor", [ObjectType.Number], function(p) {
            final value = cast(p[0], NumberObj).value;

            return new NumberObj(Math.floor(value), evaluator);
        });

        addFunctionMember("sqrt", [ObjectType.Number], function(p) {
            final value = cast(p[0], NumberObj).value;

            return new NumberObj(Math.sqrt(value), evaluator);
        });

        addFunctionMember("random", [], function(p) {
            return new NumberObj(Math.random(), evaluator);
        });

        addFunctionMember("pow", [ObjectType.Number, ObjectType.Number], function(p) {
            final value = cast(p[0], NumberObj).value;
            final exponent = cast(p[1], NumberObj).value;

            return new NumberObj(Math.pow(value, exponent), evaluator);
        });
    }
}