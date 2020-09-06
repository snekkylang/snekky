package evaluator.builtin.functions;

import object.ObjectWrapper;
import object.objects.Object;

class Function {

    final evaluator:Evaluator;

    public function new(evaluator:Evaluator) {
        this.evaluator = evaluator;
    }

    function returnValue(value:Object = null) {
        if (value != null) {
            evaluator.stack.add(new ObjectWrapper(value));
        }

        evaluator.callStack.pop();
    }

    public function execute() { }
}