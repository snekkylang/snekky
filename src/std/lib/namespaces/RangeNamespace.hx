package std.lib.namespaces;

import object.HashObj;
import object.Object.ObjectType;
import object.NumberObj;
import evaluator.Evaluator;

private class ExclusiveRange extends MemberObject {

    public function new(evaluator:Evaluator, start:Float, end:Float) {
        super(evaluator);

        var current = start - 1;

        addFunctionMember("next", 0, function(p) {
            current++;
            return new NumberObj(current, evaluator);
        });

        addFunctionMember("hasNext", 0, function(p) {
            return new NumberObj(current + 1 < end ? 1 : 0, evaluator);
        });

        addFunctionMember("Iterator", 0, function(p) {
            return new ExclusiveRange(evaluator, start, end).getMembers();
        });
    }
}

class RangeNamespace extends MemberObject {

    public static final name = "Range";

    public function new(evaluator:Evaluator) {
        super(evaluator);

        addFunctionMember("Exclusive", 2, function(p) {
            assertParameterType(p[0], ObjectType.Number);
            assertParameterType(p[1], ObjectType.Number);
            final start = cast(p[0], NumberObj).value;
            final end = cast(p[1], NumberObj).value;

            return new ExclusiveRange(evaluator, start, end).getMembers();
        });

        addFunctionMember("Inclusive", 2, function(p) {
            assertParameterType(p[0], ObjectType.Number);
            assertParameterType(p[1], ObjectType.Number);
            final start = cast(p[0], NumberObj).value;
            final end = cast(p[1], NumberObj).value + 1;

            return new ExclusiveRange(evaluator, start, end).getMembers();
        });
    }
}