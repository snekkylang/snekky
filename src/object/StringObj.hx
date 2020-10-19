package object;

import evaluator.Evaluator;
import object.Object.ObjectType;

class StringObj extends Object {

    public final value:String;

    public function new(value:String, evaluator:Evaluator) {
        super(ObjectType.String, evaluator);

        this.value = value;

        if (evaluator == null) {
            return;
        }

        addFunctionMember("toString", 0, function(p) {
            return new StringObj(toString(), evaluator);
        });

        addFunctionMember("length", 0, function(p) {
            return new NumberObj(this.value.length, evaluator);
        });

        addFunctionMember("charAt", 1, function(p) {
            assertParameterType(p[0], ObjectType.Number);
            final index = Std.int(cast(p[0], NumberObj).value);
            final v = this.value.charAt(index);
            return v == null ? new NullObj(evaluator) : new StringObj(v, evaluator);
        });

        addFunctionMember("split", 1, function(p) {
            assertParameterType(p[0], ObjectType.String);
            final separator = cast(p[0], StringObj).value;
            final arr:Array<Object> = [];
            for (v in this.value.split(separator)) {
                arr.push(new StringObj(v, evaluator));
            }
            return new ArrayObj(arr, evaluator);
        });
    }

    override function toString():String {
        return value;
    }
}