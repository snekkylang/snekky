package evaluator.builtin.functions;

import object.objects.StringObj;
import object.objects.FloatObj;
import object.ObjectType;

class PrintFunc extends Function {

    public function new(evaluator:Evaluator) {
        super(evaluator);
    }

    override function execute() {
        final parameter = evaluator.stack.pop();

        switch (parameter.type) {
            case ObjectType.Float: Sys.println(cast(parameter, FloatObj).value);
            case ObjectType.String: Sys.println(cast(parameter, StringObj).value);
            case ObjectType.Function: Sys.println("#func");
            default:
        }

        returnValue();
    }
}