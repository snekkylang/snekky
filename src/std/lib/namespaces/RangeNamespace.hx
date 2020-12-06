package std.lib.namespaces;

import object.BooleanObj;
import object.Object.ObjectType;
import object.NumberObj;
import evaluator.Evaluator;

private class ExclusiveRange extends MemberObject {

    public function new(evaluator:Evaluator, start:Float, end:Float) {
        super(evaluator);

        var current = start - 1;

        addFunctionMember("next", [], function(p) {
            current++;
            return new NumberObj(current, evaluator);
        });

        addFunctionMember("hasNext", [], function(p) {
            return new BooleanObj(current + 1 < end, evaluator);
        });

        addFunctionMember("Iterator", [], function(p) {
            return new ExclusiveRange(evaluator, start, end).getMembers();
        });
    }
}

class RangeNamespace extends MemberObject {

    public static final name = "Range";

    public function new(evaluator:Evaluator) {
        super(evaluator);

        addFunctionMember("Exclusive", [ObjectType.Number, ObjectType.Number], function(p) {
            final start = cast(p[0], NumberObj).value;
            final end = cast(p[1], NumberObj).value;

            return new ExclusiveRange(evaluator, start, end).getMembers();
        });

        addFunctionMember("Inclusive", [ObjectType.Number, ObjectType.Number], function(p) {
            final start = cast(p[0], NumberObj).value;
            final end = cast(p[1], NumberObj).value + 1;

            return new ExclusiveRange(evaluator, start, end).getMembers();
        });
    }
}