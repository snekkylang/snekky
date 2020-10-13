package std.lib;

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

    public function getObject():Object {
        return Object.Hash(members);
    }

    function addFunctionMember(memberName:String, parametersCount:Int, memberFunction:Array<Object>->Object) {
        members.set(memberName, Object.Closure(Object.BuiltInFunction(memberFunction, parametersCount), evaluator.currentFrame));
    } 

    function addObjectMember(name:String, object:Object) {
        members.set(name, object);
    }

    function error(message:String) {
        evaluator.error.error(message);
    }
}