package evaluator.builtin.functions;

import object.ObjectWrapper;

class Function {

    final evaluator:Evaluator;

    public function new(evaluator:Evaluator) {
        this.evaluator = evaluator;
    }

    function returnValue(value:ObjectWrapper = null) {
        if (value != null) {
            evaluator.stack.add(value);
        }

        evaluator.callStack.pop();
    }

    public function execute() { }
}