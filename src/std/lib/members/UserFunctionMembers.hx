package std.lib.members;

import object.Object;
import evaluator.Evaluator;

using object.ObjectHelper;

class UserFunctionMembers extends MemberObject {

    public function new(evaluator:Evaluator) {
        super(evaluator);

        addFunctionMember("toString", 1, function(parameters) {
            return Object.String(parameters[0].toString());
        });
    }
}