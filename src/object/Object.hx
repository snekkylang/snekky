package object;

import evaluator.Evaluator;
import std.lib.MemberObject;

enum ObjectType {
    Number;
    Boolean;
    String;
    Array;
    Hash;
    BuiltInFunction;
    UserFunction;
    Closure;
    Null;
}

class Object extends MemberObject {

    public final type:ObjectType;

    public function new(type:ObjectType, evaluator:Evaluator) {
        super(evaluator);

        this.type = type;
    }

    public function toString():String {
        return "#object";
    }

    public function equals(o:Object):Bool {
        return false;
    }

    public function clone():Object {
        return null;
    }
}