package std.lib.namespaces;

import object.BooleanObj;
import object.Object.ObjectType;
import object.StringObj;
import evaluator.Evaluator;

class Regex extends MemberObject {

    public function new(evaluator:Evaluator, regex:EReg) {
        super(evaluator);

        addFunctionMember("match", [ObjectType.String], function(p) {
            final s = cast(p[0], StringObj).value;

            return new BooleanObj(regex.match(s), evaluator);
        });

        addFunctionMember("replace", [ObjectType.String, ObjectType.String], function(p) {
            final s = cast(p[0], StringObj).value;
            final by = cast(p[1], StringObj).value;

            return new StringObj(regex.replace(s, by), evaluator);
        });
    }
}

class RegexNamespace extends MemberObject {

    public static final name = "Regex";

    public function new(evaluator:Evaluator) {
        super(evaluator);

        addFunctionMember("compile", [ObjectType.String, ObjectType.String], function(p) {
            final pattern = cast(p[0], StringObj).value;
            final flags = cast(p[1], StringObj).value;
            
            return new Regex(evaluator, new EReg(pattern, flags)).getMembers();
        });
    }
}