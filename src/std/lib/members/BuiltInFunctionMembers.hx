package std.lib.members;

import evaluator.Evaluator;

using object.ObjectHelper;

class BuiltInFunctionMembers extends MemberObject {

    public function new(evaluator:Evaluator) {
        super(evaluator);

        addFunctionMember("to_string", 1, function(parameters) {
            return Object.String(parameters[0].toString());
        });
    }
}