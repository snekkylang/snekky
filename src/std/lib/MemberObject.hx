package std.lib;

import object.ClosureObj;
import object.HashObj;
import object.BuiltInFunctionObj;
import haxe.ds.StringMap;
import evaluator.Evaluator;
import object.Object;

class MemberObject {

    public static final name:String = null;
    final members:StringMap<Object> = new StringMap();
    final evaluator:Evaluator;

    public function new(evaluator:Evaluator) {
        this.evaluator = evaluator;
    }

    public function getMembers():HashObj {
        return new HashObj(members, evaluator);
    }

    function addFunctionMember(memberName:String, parameters:Array<ObjectType>, memberFunction:Array<Object>->Object) {
        members.set(memberName, new ClosureObj(new BuiltInFunctionObj(memberFunction, parameters, evaluator), evaluator.currentFrame, evaluator));
    }

    function callFunctionMember(name:String, parameters:Array<Object>):Object {
        final func = cast(members.get(name), ClosureObj);
        return evaluator.callFunction(func, parameters);
    }

    function addObjectMember(name:String, object:Object) {
        members.set(name, object);
    }

    function error(message:String) {
        evaluator.error.error(message);
    }
}