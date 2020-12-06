package object;

import evaluator.Evaluator;
import object.Object.ObjectType;

private typedef BuiltInFunction = Array<Object>->Object;

class BuiltInFunctionObj extends Function {

    public final func:BuiltInFunction;
    public final parameters:Array<ObjectType>;

    public function new(func:BuiltInFunction, parameters:Array<ObjectType>, evaluator:Evaluator) {
        super(ObjectType.BuiltInFunction, parameters.length, evaluator);

        this.func = func;
        this.parameters = parameters;
    }

    override function toString():String {
        return "#func(BuiltIn)";
    }

    override function equals(o:Object):Bool {
        if (o.type != ObjectType.BuiltInFunction) {
            return false;
        }

        return cast(o, BuiltInFunctionObj).func == func;
    }
}