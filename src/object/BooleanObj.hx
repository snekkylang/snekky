package object;

import object.Object.ObjectType;
import evaluator.Evaluator;

class BooleanObj extends Object {

    public final value:Bool;

    public function new(value:Bool, evaluator:Evaluator) {
        super(ObjectType.Boolean, evaluator);

        this.value = value;
    }

    override function toString():String {
        return value ? "true" : "false";
    }

    override function equals(o:Object):Bool {
        if (o.type != ObjectType.Boolean) {
            return false;
        }

        return cast(o, BooleanObj).value == value;
    }
}