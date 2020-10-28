package std;

import object.BuiltInFunctionObj;
import std.lib.MemberObject;
import std.lib.namespaces.*;
import evaluator.Evaluator;
import object.Object;

typedef MemberFunction = {parametersCount:Int, memberFunction:Array<Object>->Object};

class BuiltInTable {

    final namespaces:Array<MemberObject>;
    final evaluator:Evaluator;

    public function new(evaluator:Evaluator) {
        this.evaluator = evaluator;

        namespaces = [
            new SysNamespace(evaluator),
            new MathNamespace(evaluator),
            new NumberNamespace(evaluator),
            new ObjectNamespace(evaluator),
            new RangeNamespace(evaluator),
            new RegexNamespace(evaluator),
            #if target.sys
            new FileNamespace(evaluator), 
            new HttpNamespace(evaluator)
            #end
        ];
    }

    public static function resolveName(name:String):Int {
        return [
            SysNamespace.name,
            MathNamespace.name,
            NumberNamespace.name,
            ObjectNamespace.name,
            RangeNamespace.name,
            RegexNamespace.name,
            #if target.sys
            FileNamespace.name, 
            HttpNamespace.name
            #end
        ].indexOf(name);
    }

    public function resolveIndex(index:Int):Object {
        return namespaces[index].getMembers();
    }

    public function callFunction(func:BuiltInFunctionObj) {
        final parameters:Array<Object> = [];

        for (_ in 0...func.parametersCount) {
            final parameter = evaluator.stack.pop();

            parameters.push(parameter);
        }

        final returnValue = func.func(parameters);
        evaluator.stack.add(returnValue);
        evaluator.frames.pop();
        evaluator.currentFrame = evaluator.frames.first();
    }
}
