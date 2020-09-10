package evaluator.builtin.functions;

import object.Object;

class PrintFunc extends Function {

    public function new(evaluator:Evaluator) {
        super(evaluator);
    }

    override function execute() {
        final parameter = evaluator.stack.pop();

        if (parameter == null) {
            evaluator.error.error("wrong number of arguments to function");
        }

        final stringValue = switch (parameter) {
            case Object.String(value): value;
            case Object.Float(value): Std.string(value);
            case Object.Array(value): Std.string(value);
            case Object.Hash(value): Std.string(value);
            case Object.Function(index, origin): '#func($index, $origin)';
        }

        Sys.print(stringValue);

        returnValue();
    }
}