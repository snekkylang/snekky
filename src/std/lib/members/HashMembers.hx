package std.lib.members;

import object.Object;
import evaluator.Evaluator;
using object.ObjectHelper;

class HashMembers extends MemberObject {
  
    public function new(evaluator:Evaluator) {
        super(evaluator);

        addFunctionMember("to_string", 1, function(parameters) {
            return Object.String(parameters[0].toString());
        });

        addFunctionMember("length", 1, function(parameters) {
            return switch (parameters[0]) {
                case Object.Hash(values): Object.Float(Lambda.count(values));
                default: Object.Null;
            }
        });
    }
}