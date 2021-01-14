package std.lib.namespaces;

import object.BooleanObj;
import object.Object.ObjectType;
import object.NumberObj;
import vm.VirtualMachine;

private class ExclusiveRange extends MemberObject {

    public function new(vm:VirtualMachine, start:Float, end:Float) {
        super(vm);

        var current = start - 1;

        addFunctionMember("next", [], function(p) {
            current++;
            return new NumberObj(current, vm);
        });

        addFunctionMember("hasNext", [], function(p) {
            return new BooleanObj(current + 1 < end, vm);
        });

        addFunctionMember("Iterator", [], function(p) {
            return new ExclusiveRange(vm, start, end).getMembers();
        });
    }
}

class RangeNamespace extends MemberObject {

    public static final name = "Range";

    public function new(vm:VirtualMachine) {
        super(vm);

        addFunctionMember("Exclusive", [ObjectType.Number, ObjectType.Number], function(p) {
            final start = cast(p[0], NumberObj).value;
            final end = cast(p[1], NumberObj).value;

            return new ExclusiveRange(vm, start, end).getMembers();
        });

        addFunctionMember("Inclusive", [ObjectType.Number, ObjectType.Number], function(p) {
            final start = cast(p[0], NumberObj).value;
            final end = cast(p[1], NumberObj).value + 1;

            return new ExclusiveRange(vm, start, end).getMembers();
        });
    }
}