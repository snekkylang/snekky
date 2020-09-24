package std.lib.namespaces;

import object.Object;
import evaluator.Evaluator;

class ArrayNamespace extends Namespace {

    public static final name = "Array";

    public function new(evaluator:Evaluator) {
        super(evaluator);

        addFunctionMember("push", 2, function(parameters) {
            switch (parameters[0]) {
                case Array(values): values.push(parameters[1]);
                default: error('expected Array, got ${parameters[1].getName()}');
            }

            return Object.Null;
        });

        addFunctionMember("pop", 1, function(parameters) {
            switch (parameters[0]) {
                case Array(values):
                    final popped = values.pop();
                    return (popped == null) ? Object.Null : popped;
                default: error('expected Array, got ${parameters[1].getName()}');
            }

            return Object.Null;
        });

        addFunctionMember("length", 1, function(parameters) {
            switch (parameters[0]) {
                case Array(values): return Object.Float(values.length);
                default: error('expected Array, got ${parameters[1].getName()}');
            }

            return Object.Null;    
        });
    }
}