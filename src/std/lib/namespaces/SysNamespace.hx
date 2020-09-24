package std.lib.namespaces;

import object.Object;
import evaluator.Evaluator;

using object.ObjectHelper;

class SysNamespace extends Namespace {

    public static final name = "Sys";

    public function new(evaluator:Evaluator) {
        super(evaluator);

        addFunctionMember("println", 1, function(parameters) {
            Sys.println(parameters[0].toString());

            return Object.Null;
        });
    }
}