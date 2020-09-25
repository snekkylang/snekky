package std.lib.namespaces;

import object.Object;
import evaluator.Evaluator;

class ArrayNamespace extends Namespace {

    public static final name = "Array";

    public function new(evaluator:Evaluator) {
        super(evaluator);

        addFunctionMember("push", 2, function(parameters) {
            switch (parameters[0]) {
                case Object.Array(values): values.push(parameters[1]);
                default: error('expected Array, got ${parameters[1].getName()}');
            }

            return Object.Null;
        });

        addFunctionMember("pop", 1, function(parameters) {
            switch (parameters[0]) {
                case Object.Array(values):
                    final popped = values.pop();
                    return (popped == null) ? Object.Null : popped;
                default: error('expected Array, got ${parameters[1].getName()}');
            }

            return Object.Null;
        });

        addFunctionMember("length", 1, function(parameters) {
            switch (parameters[0]) {
                case Object.Array(values): return Object.Float(values.length);
                default: error('expected Array, got ${parameters[1].getName()}');
            }

            return Object.Null;    
        });

        addFunctionMember("map", 2, function(parameters) {
            switch [parameters[0], parameters[1]] {
                case [Object.Array(array), Object.UserFunction(_)]:
                    for (k => v in array) {
                        array[k] = evaluator.callFunction(parameters[1], [v]);
                    }
                default: error('expected Array, got ${parameters[1].getName()}');
            }

            return Object.Null;
        });
    }
}