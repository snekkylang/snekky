package evaluator.builtin.functions;

import object.objects.ArrayObj;

class ArrayPushFunc extends Function {

    public function new(evaluator:Evaluator) {
        super(evaluator);
    }

    override function execute() {
        try {
            final array = cast(evaluator.stack.pop(), ArrayObj);
            final value = evaluator.stack.pop();

            array.push(value);

            returnValue();
        } catch (e) {
            evaluator.error.error("first parameter must be an array");
        }
    }
}