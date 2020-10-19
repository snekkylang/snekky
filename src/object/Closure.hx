package object;

import evaluator.Evaluator;
import object.Object.ObjectType;
import evaluator.Frame;

using equals.Equal;

class ClosureObj extends Object {

    public final func:Function;
    public final context:Frame;

    public function new(func:Function, context:Frame, evaluator:Evaluator) {
        super(ObjectType.Closure, evaluator);

        this.func = func;
        this.context = context;
    }

    override function getMembers():HashObj {
        return func.getMembers();
    }

    override function toString():String {
        return '#closure(${func.toString()})';
    }
}