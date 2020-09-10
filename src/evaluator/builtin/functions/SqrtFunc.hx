package evaluator.builtin.functions;

import object.Object;

class SqrtFunc extends Function {

    public function new(evaluator:Evaluator) {
        super(evaluator);
    }

    override function execute() {
        final parameter = evaluator.stack.pop();

        switch (parameter) {
            case Object.Float(value):
                returnValue(Object.Float(Math.sqrt(value)));
            default: evaluator.error.error("first parameter must be a float");
        }
    }
}