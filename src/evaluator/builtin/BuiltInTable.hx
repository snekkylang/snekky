package evaluator.builtin;

import evaluator.builtin.functions.*;

class BuiltInTable {

    final evaluator:Evaluator;
    final functions:Array<Function>;
    static final symbols:Array<String> = [
        "print",
        "array_length",
        "array_push",
        "sqrt"
    ];

    public function new(evaluator:Evaluator) {
        this.evaluator = evaluator;

        functions = [
            new PrintFunc(evaluator),
            new ArrayLengthFunc(evaluator),
            new ArrayPushFunc(evaluator),
            new SqrtFunc(evaluator)
        ];
    }

    public static function getSymbolIndex(name:String):Int {
        return symbols.indexOf(name);
    }

    public function execute(index:Int) {
        functions[index].execute();
    }
}