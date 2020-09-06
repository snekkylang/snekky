package evaluator.builtin.functions;

import object.objects.ArrayObj;

class ArrayPushFunc extends Function {

    public function new(evaluator:Evaluator) {
        super(evaluator);
    }

    override function execute() {
        try {
            final array = cast(evaluator.stack.pop().object, ArrayObj);
            final value = evaluator.stack.pop();

            array.push(value);
            
            returnValue();
        } catch (e) {
            evaluator.error.error("parameter is not an array");
        }
    }
}
