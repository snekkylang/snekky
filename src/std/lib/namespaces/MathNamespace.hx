package std.lib.namespaces;

import object.Object;
import evaluator.Evaluator;

class MathNamespace extends MemberObject {

    public static final name = "Math";

    public function new(evaluator:Evaluator) {
        super(evaluator);

        addObjectMember("PI", Object.Number(Math.PI));

        addFunctionMember("abs", 1, function(parameters) {
            switch (parameters[0]) {
                case Object.Number(value): return Object.Number(Math.abs(value));
                default: error('expected Float, got ${parameters[1].getName()}');
            }
            
            return Object.Null;
        });

        addFunctionMember("floor", 1, function(parameters) {
            switch (parameters[0]) {
                case Object.Number(value): return Object.Number(Math.floor(value));
                default: error('expected Float, got ${parameters[1].getName()}');
            }
            
            return Object.Null;
        });

        addFunctionMember("sqrt", 1, function(parameters) {
            switch (parameters[0]) {
                case Object.Number(value): return Object.Number(Math.sqrt(value));
                default: error('expected Float, got ${parameters[1].getName()}');
            }
            
            return Object.Null;
        });
    }
}