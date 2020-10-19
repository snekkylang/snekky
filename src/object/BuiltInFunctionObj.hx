package object;

import evaluator.Evaluator;
import object.Object.ObjectType;

private typedef BuiltInFunction = Array<Object>->Object;

class BuiltInFunctionObj extends Function {

    public final func:BuiltInFunction;

    public function new(func:BuiltInFunction, parametersCount:Int, evaluator:Evaluator) {
        super(ObjectType.BuiltInFunction, parametersCount, evaluator);

        this.func = func;

        if (evaluator == null) {
            return;
        }
    }

    override function toString():String {
        return "#func(BuiltIn)";
    }
}