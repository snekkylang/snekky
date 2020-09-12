package evaluator.builtin.functions;

import object.Object;

class Function {

    final evaluator:Evaluator;

    public function new(evaluator:Evaluator) {
        this.evaluator = evaluator;
    }

    function returnValue(value:Object = Object.Null) {
        evaluator.stack.add(value);

        evaluator.callStack.pop();
    }

    public function execute() { }
}