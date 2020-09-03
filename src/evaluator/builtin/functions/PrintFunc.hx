package evaluator.builtin.functions;

class PrintFunc extends Function {

    public function new(evaluator:Evaluator) {
        super(evaluator);
    }

    override function execute() {
        final parameter = evaluator.stack.pop();

        if (parameter == null) {
            evaluator.error.error("wrong number of arguments to function");
        }

        Sys.println(parameter.toString());

        returnValue();
    }
}