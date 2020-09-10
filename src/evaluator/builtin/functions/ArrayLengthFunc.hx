package evaluator.builtin.functions;

import object.Object;

class ArrayLengthFunc extends Function {

    public function new(evaluator:Evaluator) {
        super(evaluator);
    }

    override function execute() {
        final array = evaluator.stack.pop();

        switch (array) {
            case Object.Array(values):
                returnValue(Object.Float(values.length));
            default: evaluator.error.error("first parameter must be an array");
        }
    }
}