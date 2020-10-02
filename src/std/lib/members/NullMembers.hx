package std.lib.members;

import evaluator.Evaluator;
using object.ObjectHelper;

class NullMembers extends MemberObject {
 
    public function new(evaluator:Evaluator) {
        super(evaluator);

        addFunctionMember("toString", 1, function(parameters) {
            return Object.String(parameters[0].toString());
        });
    }
}