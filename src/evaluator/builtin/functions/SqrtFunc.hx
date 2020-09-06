package evaluator.builtin.functions;

import object.objects.FloatObj;

class SqrtFunc extends Function {

    public function new(evaluator:Evaluator) {
        super(evaluator);
    }

    override function execute() {
        try {
            final value = cast(evaluator.stack.pop().object, FloatObj);

            returnValue(new FloatObj(Math.sqrt(value.value)));
        } catch (e) {
            evaluator.error.error("first parameter must be a float");
        }
    }
}