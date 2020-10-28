package std.lib;

import object.HashObj;
import object.BuiltInFunctionObj;
import object.Closure.ClosureObj;
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

    function addFunctionMember(memberName:String, parametersCount:Int, memberFunction:Array<Object>->Object) {
        members.set(memberName, new ClosureObj(new BuiltInFunctionObj(memberFunction, parametersCount, evaluator), evaluator.currentFrame, evaluator));
    }

    function callFunctionMember(name:String, parameters:Array<Object>) {
        final func = cast(members.get(name), ClosureObj);
        evaluator.callFunction(func, parameters);
    }

    function addObjectMember(name:String, object:Object) {
        members.set(name, object);
    }

    function error(message:String) {
        evaluator.error.error(message);
    }

    function assertParameterType(p:Object, expected:ObjectType) {
        if (p.type != expected) {
            error('expected $expected, got ${p.type}');
        }
    }
}