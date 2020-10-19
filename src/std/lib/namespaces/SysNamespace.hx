package std.lib.namespaces;

import object.StringObj;
import object.NullObj;
import evaluator.Evaluator;

class SysNamespace extends MemberObject {

    public static final name = "Sys";

    public function new(evaluator:Evaluator) {
        super(evaluator);

        addFunctionMember("println", 1, function(p) {
            Sys.println(p[0].toString());

            return new NullObj(evaluator);
        });

        addFunctionMember("print", 1, function(p) {
            Sys.print(p[0].toString());

            return new NullObj(evaluator);
        });

        addFunctionMember("readLine", 0, function(p) {
            final input = Sys.stdin().readLine();

            return new StringObj(input, evaluator);
        });
    }
}