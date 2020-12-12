package object;

import evaluator.Evaluator;
import object.Object.ObjectType;

class NumberObj extends Object {

    public final value:Float;

    public function new(value:Float, evaluator:Evaluator) {
        super(ObjectType.Number, evaluator);

        this.value = value;

        if (evaluator == null) {
            return;
        }

        addFunctionMember("toString", [], function(p) {
            return new StringObj(toString(), evaluator);
        });
    }

    override function toString():String {
        return Std.string(value);
    }

    override function equals(o:Object):Bool {
        if (o.type != ObjectType.Number) {
            return false;
        }

        return cast(o, NumberObj).value == value;
    }

    override function clone():Object {
        return new NumberObj(value, evaluator);
    }
}