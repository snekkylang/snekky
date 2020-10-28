package std.lib.namespaces;

import object.NumberObj;
import object.Object.ObjectType;
import object.StringObj;
import evaluator.Evaluator;

class Regex extends MemberObject {

    public function new(evaluator:Evaluator, regex:EReg) {
        super(evaluator);

        addFunctionMember("match", 1, function(p) {
            assertParameterType(p[0], ObjectType.String);
            final s = cast(p[0], StringObj).value;

            return new NumberObj(regex.match(s) ? 1: 0, evaluator);
        });

        addFunctionMember("replace", 2, function(p) {
            assertParameterType(p[0], ObjectType.String);
            final s = cast(p[0], StringObj).value;

            assertParameterType(p[1], ObjectType.String);
            final by = cast(p[1], StringObj).value;

            return new StringObj(regex.replace(s, by), evaluator);
        });
    }
}

class RegexNamespace extends MemberObject {

    public static final name = "Regex";

    public function new(evaluator:Evaluator) {
        super(evaluator);

        addFunctionMember("compile", 2, function(p) {
            assertParameterType(p[0], ObjectType.String);
            final pattern = cast(p[0], StringObj).value;

            assertParameterType(p[1], ObjectType.String);
            final flags = cast(p[1], StringObj).value;
            
            return new Regex(evaluator, new EReg(pattern, flags)).getMembers();
        });
    }
}