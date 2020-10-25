package std.lib.namespaces;

import haxe.Log;
import object.StringObj;
import object.NullObj;
import evaluator.Evaluator;

class SysNamespace extends MemberObject {

    public static final name = "Sys";

    public function new(evaluator:Evaluator) {
        super(evaluator);

        addFunctionMember("println", 1, function(p) {
            #if target.sys
            Sys.println(p[0].toString());
            #else
            js.Browser.console.log(p[0].toString());
            #end

            return new NullObj(evaluator);
        });

        addFunctionMember("print", 1, function(p) {
            #if target.sys
            Sys.print(p[0].toString());
            #else
            js.Browser.console.log(p[0].toString());
            #end

            return new NullObj(evaluator);
        });

        addFunctionMember("readLine", 0, function(p) {
            #if target.sys
            final input = Sys.stdin().readLine();
            #else
            final input = "";
            throw "Read line not supported on this target";
            #end

            return new StringObj(input, evaluator);
        });
    }
}