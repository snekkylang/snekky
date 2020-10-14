package std;

import std.lib.members.NullMembers;
import std.lib.members.HashMembers;
import std.lib.members.BuiltInFunctionMembers;
import std.lib.members.UserFunctionMembers;
import std.lib.members.FloatMembers;
import std.lib.members.StringMembers;
import std.lib.members.ArrayMembers;
import std.lib.MemberObject;
import std.lib.namespaces.*;
import evaluator.Evaluator;
import object.Object;

typedef MemberFunction = {parametersCount:Int, memberFunction:Array<Object>->Object};

class BuiltInTable {

    final namespaces:Array<MemberObject>;
    final members:Array<MemberObject>;
    final evaluator:Evaluator;

    public function new(evaluator:Evaluator) {
        this.evaluator = evaluator;

        namespaces = [
            new SysNamespace(evaluator),
            new MathNamespace(evaluator),
            new StringNamespace(evaluator),
            #if (playground != 1)
            new FileNamespace(evaluator),
            new HttpNamespace(evaluator)
            #end
        ];

        members = [
            new FloatMembers(evaluator),
            new StringMembers(evaluator),
            new UserFunctionMembers(evaluator),
            new UserFunctionMembers(evaluator),
            new BuiltInFunctionMembers(evaluator),
            new ArrayMembers(evaluator),
            new HashMembers(evaluator),
            new NullMembers(evaluator)
        ];
    }

    public static function resolveName(name:String):Int {
        return [
            SysNamespace.name,
            MathNamespace.name,
            StringNamespace.name,
            #if (playground != 1)
            FileNamespace.name,
            HttpNamespace.name
            #end
        ].indexOf(name);
    }

    public function resolveIndex(index:Int):Object {
        return namespaces[index].getObject();
    }

    public function resolveObject(obj:Object):Object {
        return members[obj.getIndex()].getObject();
    }

    public function callFunction(builtInFunction:Object) {
        final parameters:Array<Object> = [];

        switch (builtInFunction) {
            case Object.BuiltInFunction(memberFunction, parametersCount):
                for (_ in 0...parametersCount) {
                    final parameter = evaluator.stack.pop();
        
                    if (parameter == null) {
                        evaluator.error.error("wrong number of arguments to function");
                    }

                    parameters.push(parameter);
                }
        
                final returnValue = memberFunction(parameters);
                evaluator.stack.add(returnValue);
                evaluator.frames.pop();
                evaluator.currentFrame = evaluator.frames.first();
            default:
        }
    }
}