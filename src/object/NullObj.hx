package object;

import evaluator.Evaluator;
import object.Object.ObjectType;

class NullObj extends Object {

    public function new(evaluator:Evaluator) {
        super(ObjectType.Null, evaluator);

        if (evaluator == null) {
            return;
        }

        addFunctionMember("toString", 0, function(p) {
            return new StringObj(toString(), evaluator);
        });
    }

    override function toString():String {
        return "null";
    }

    override function equals(o:Object):Bool {
        return o.type == ObjectType.Null;
    }
}