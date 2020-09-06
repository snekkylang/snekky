package evaluator.builtin;

import evaluator.builtin.functions.*;

class BuiltInTable {

    final evaluator:Evaluator;
    final functions:Array<Function>;

    public function new(evaluator:Evaluator) {
        this.evaluator = evaluator;

        functions = [
            new PrintFunc(evaluator)
        ];
    }

    public function execute(index:Int) {
        functions[index].execute();
    }
}