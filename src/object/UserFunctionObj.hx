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

        addFunctionMember("toString", 0, function(p) {
            return new StringObj(toString(), evaluator);
        });
    }

    override function toString():String {
        return 'func($position, UserDefined)';
    }
}