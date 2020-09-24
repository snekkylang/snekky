package std;

import std.lib.Namespace;
import std.lib.namespaces.*;
import evaluator.Evaluator;
import object.Object;

typedef MemberFunction = {parametersCount:Int, memberFunction:Array<Object>->Object};

class BuiltInTable {

    final namespaces:Array<Namespace>;
    final evaluator:Evaluator;

    public function new(evaluator:Evaluator) {
        this.evaluator = evaluator;

        namespaces = [
            new SysNamespace(evaluator),
            new ArrayNamespace(evaluator),
            new MathNamespace(evaluator),
            #if (playground != 1)
            new FileNamespace(evaluator),
            #end
            new StringNamespace(evaluator)
        ];
    }

    public static function resolveName(name:String):Int {
        return [
            SysNamespace.name,
            ArrayNamespace.name,
            MathNamespace.name,
            #if (playground != 1)
            FileNamespace.name,
            #end
            StringNamespace.name
        ].indexOf(name);
    }

    public function resolveIndex(index:Int):Object {
        return namespaces[index].getObject();
    }

    public function callFunction(memberFunction:MemberFunction) {
        final parameters:Array<Object> = [];

        for (_ in 0...memberFunction.parametersCount) {
            final parameter = evaluator.stack.pop();

            if (parameter == null) {
                evaluator.error.error('wrong number of arguments to function');
            }

            parameters.push(parameter);
        }

        final returnValue = memberFunction.memberFunction(parameters);
        evaluator.stack.add(returnValue);
        evaluator.callStack.pop();
    }
}