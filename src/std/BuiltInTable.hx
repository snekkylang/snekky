package std;

import std.lib.namespaces.io.IoNamespace;
import std.lib.namespaces.json.*;
import std.lib.namespaces.net.*;
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
            new JsonNamespace(evaluator),
            new IoNamespace(evaluator),
            #if target.sys
            new FileNamespace(evaluator), 
            new HttpNamespace(evaluator),
            new ThreadNamespace(evaluator),
            new NetNamespace(evaluator)
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
            JsonNamespace.name,
            IoNamespace.name,
            #if target.sys
            FileNamespace.name, 
            HttpNamespace.name,
            ThreadNamespace.name,
            NetNamespace.name
            #end
        ].indexOf(name);
    }

    public function resolveIndex(index:Int):Object {
        return namespaces[index].getMembers();
    }

    public function callFunction(func:BuiltInFunctionObj) {
        final parameters:Array<Object> = [];

        for (i in 0...func.parametersCount) {
            final parameter = evaluator.stack.pop();

            if (func.parameters[i] != null && parameter.type != func.parameters[i]) {
                evaluator.error.error('expected ${(func.parameters[i])}, got ${parameter.type}'); 
            }

            parameters.push(parameter);
        }

        final returnValue = func.func(parameters);
        evaluator.stack.add(returnValue);
        evaluator.frames.pop();
        evaluator.currentFrame = evaluator.frames.first();
    }
}
