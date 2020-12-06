package object;

import evaluator.Evaluator;
import object.Object.ObjectType;

class UserFunctionObj extends Function {

    public final position:Int;

    public function new(position:Int, parametersCount:Int, evaluator:Evaluator) {
        super(ObjectType.UserFunction, parametersCount, evaluator);

        this.position = position;

        if (evaluator == null) {
            return;
        }

        addFunctionMember("toString", [], function(p) {
            return new StringObj(toString(), evaluator);
        });
    }

    override function toString():String {
        return '#func($position, UserDefined)';
    }

    override function equals(o:Object):Bool {
        if (o.type != ObjectType.UserFunction) {
            return false;
        }

        return cast(o, UserFunctionObj).position == position;
    }
}