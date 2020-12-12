package object;

import evaluator.Evaluator;
import object.Object.ObjectType;
import evaluator.Frame;

class ClosureObj extends Object {

    public final func:Function;
    public var context:Frame;

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

    override function equals(o:Object):Bool {
        if (o.type != ObjectType.Closure) {
            return false;
        }

        return cast(o, ClosureObj).func == func;
    }

    override function clone():Object {
        return new ClosureObj(func, context, evaluator);
    }
}