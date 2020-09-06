package evaluator.builtin.functions;

import object.objects.FloatObj;
import object.objects.ArrayObj;

class ArrayLengthFunc extends Function {

    public function new(evaluator:Evaluator) {
        super(evaluator);
    }

    override function execute() {
        try {
            final array = cast(evaluator.stack.pop().object, ArrayObj);

            returnValue(new FloatObj(array.values.length));
        } catch (e) {
            evaluator.error.error("parameter is not an array");
        }
    }
}
