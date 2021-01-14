package std.lib.namespaces;

import object.NumberObj;
import object.Object;
import vm.VirtualMachine;

class MathNamespace extends MemberObject {

    public static final name = "Math";

    public function new(vm:VirtualMachine) {
        super(vm);

        addObjectMember("PI", new NumberObj(Math.PI, vm));

        addFunctionMember("abs", [ObjectType.Number], function(p) {
            final value = cast(p[0], NumberObj).value;

            return new NumberObj(Math.abs(value), vm);
        });

        addFunctionMember("floor", [ObjectType.Number], function(p) {
            final value = cast(p[0], NumberObj).value;

            return new NumberObj(Math.floor(value), vm);
        });

        addFunctionMember("sqrt", [ObjectType.Number], function(p) {
            final value = cast(p[0], NumberObj).value;

            return new NumberObj(Math.sqrt(value), vm);
        });

        addFunctionMember("random", [], function(p) {
            return new NumberObj(Math.random(), vm);
        });

        addFunctionMember("pow", [ObjectType.Number, ObjectType.Number], function(p) {
            final value = cast(p[0], NumberObj).value;
            final exponent = cast(p[1], NumberObj).value;

            return new NumberObj(Math.pow(value, exponent), vm);
        });
    }
}