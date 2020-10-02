package std.lib.namespaces;

import object.Object;
import evaluator.Evaluator;

using object.ObjectHelper;

class SysNamespace extends MemberObject {

    public static final name = "Sys";

    public function new(evaluator:Evaluator) {
        super(evaluator);

        addFunctionMember("println", 1, function(parameters) {
            Sys.println(parameters[0].toString());

            return Object.Null;
        });

        addFunctionMember("print", 1, function(parameters) {
            Sys.print(parameters[0].toString());

            return Object.Null;
        });

        addFunctionMember("read_line", 0, function(parameters) {
            final input = Sys.stdin().readLine();

            return Object.String(input);
        });
    }
}