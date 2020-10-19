package object;

import evaluator.Evaluator;
import object.Object.ObjectType;

class Function extends Object {

    public final parametersCount:Int;

    public function new(type:ObjectType, parametersCount:Int, evaluator:Evaluator) {
        super(type, evaluator);

        this.parametersCount = parametersCount;
    }
}