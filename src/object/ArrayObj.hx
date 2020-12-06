package object;

import std.lib.MemberObject;
import evaluator.Evaluator;
import object.Object.ObjectType;

using equals.Equal;

private class ArrayIterator extends MemberObject {

    public function new(evaluator:Evaluator, value:Array<Object>) {
        super(evaluator);

        var index = -1;

        addFunctionMember("next", [], function(p) {
            index++;
            return value[index];
        });

        addFunctionMember("hasNext", [], function(p) {
            return new BooleanObj(index < value.length - 1, evaluator);
        });
    }
}

class ArrayObj extends Object {

    public final value:Array<Object>;

    public function new(value:Array<Object>, evaluator:Evaluator) {
        super(ObjectType.Array, evaluator);

        this.value = value;

        if (evaluator == null) {
            return;
        }

        addFunctionMember("Iterator", [], function(p) {
            return new ArrayIterator(evaluator, value).getMembers();
        });

        addFunctionMember("length", [], function(p) {
            return new NumberObj(this.value.length, evaluator);
        });

        addFunctionMember("toString", [], function(p) {
            return new StringObj(this.value.toString(), evaluator);
        });

        addFunctionMember("push", [null], function(p) {
            this.value.push(p[0]);

            return new NumberObj(this.value.length, evaluator);
        });

        addFunctionMember("pop", [], function(p) {
            return this.value.pop();
        });

        addFunctionMember("join", [ObjectType.String], function(p) {
            final seperator = cast(p[0], StringObj).value;

            return new StringObj(value.join(seperator), evaluator);
        });

        addFunctionMember("contains", [null], function(p) {
            for (v in value) {
                if (v.equals(p[0])) {
                    return new BooleanObj(true, evaluator);
                }
            }

            return new BooleanObj(false, evaluator);
        });

        addFunctionMember("map", [ObjectType.Closure], function(p) {
            final callback = cast(p[0], ClosureObj);
            final newArray:Array<Object> = [];

            for (v in value) {
                newArray.push(evaluator.callFunction(callback, [v]));
            }

            return new ArrayObj(newArray, evaluator);
        });

        addFunctionMember("filter", [ObjectType.Closure], function(p) {
            final callback = cast(p[0], ClosureObj);
            final newArray:Array<Object> = [];
            
            for (v in value) {
                final cbResult = evaluator.callFunction(callback, [v]);
                if (cbResult.type != ObjectType.Boolean) {
                    error("expected callback to return boolean");
                }
                final include = cast(cbResult, BooleanObj).value;
                if (include) {
                    newArray.push(v);
                }
            }

            return new ArrayObj(newArray, evaluator);
        });

        addFunctionMember("forEach", [ObjectType.Closure], function(p) {
            final callback = cast(p[0], ClosureObj);
            
            for (v in value) {
                evaluator.callFunction(callback, [v]);
            }

            return new ArrayObj(value, evaluator);
        });

        addFunctionMember("sort", [ObjectType.Closure], function(p) {
            final callback = cast(p[0], ClosureObj);

            value.sort(function(v1, v2) {
                final cbResult = evaluator.callFunction(callback, [v1, v2]);
                if (cbResult.type != ObjectType.Number) {
                    error("expected callback to return number");
                }
                final pos = Std.int(cast(cbResult, NumberObj).value);

                return pos;
            });

            return new NullObj(evaluator);
        });
    }

    override function toString():String {
        return value.map(o -> o.toString()).toString(); 
    }

    override function equals(o:Object):Bool {
        if (o.type != ObjectType.Array) {
            return false;
        }

        return cast(o, ArrayObj).value.equals(value);
    }
}