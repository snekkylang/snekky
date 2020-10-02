package std.lib.members;

import object.Object;
import evaluator.Evaluator;

using object.ObjectHelper;

class StringMembers extends MemberObject {

    public function new(evaluator:Evaluator) {
        super(evaluator);

        addFunctionMember("to_string", 1, function(parameters) {
            return Object.String(parameters[0].toString());
        });

        addFunctionMember("length", 1, function(parameters) {
            switch (parameters[0]) {
                case Object.String(value): return Object.Float(value.length);
                default: error('expected String, got ${parameters[0].getName()}');
            }

            return Object.Null;
        });

        addFunctionMember("char_at", 2, function(parameters) {
            switch [parameters[0], parameters[1]] {
                case [Object.String(string), Object.Float(index)]: return Object.String(string.charAt(Std.int(index)));
                default: error('expected String, got ${parameters[0].getName()}');
            }

            return Object.Null;
        });

        addFunctionMember("split", 2, function(parameters) {
            switch [parameters[0], parameters[1]] {
                case [Object.String(string), Object.String(separator)]: 
                    return Object.Array(string.split(separator).map(function(s) {
                        return Object.String(s);
                    }));
                default: error('expected String, got ${parameters[0].getName()}');
            }

            return Object.Null;
        });
    }
}