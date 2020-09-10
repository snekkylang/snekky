package evaluator.builtin.functions;

import object.Object;

class ArrayPushFunc extends Function {

    public function new(evaluator:Evaluator) {
        super(evaluator);
    }

    override function execute() {
        final array = evaluator.stack.pop();
        final value = evaluator.stack.pop();

        switch (array) {
            case Object.Array(values):
                values.push(value);
                returnValue();
            default: evaluator.error.error("first parameter must be an array");
        }
    }
}