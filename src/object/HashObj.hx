package object;

import evaluator.Evaluator;
import object.Object.ObjectType;
import haxe.iterators.MapKeyValueIterator;
import haxe.ds.StringMap;

using equals.Equal;

class HashObj extends Object {
    
    public final value:StringMap<Object>;

    public function new(value:StringMap<Object>, evaluator:Evaluator) {
        super(ObjectType.Hash, evaluator);

        this.value = value;

        if (evaluator == null) {
            return;
        }

        addFunctionMember("toString", 0, function(p) {
            return new StringObj(toString(), evaluator);
        });

        addFunctionMember("length", 0, function(p) {
            return new NumberObj(Lambda.count(this.value), evaluator);
        });
    }

    override function toString():String {
        final buffer = new StringBuf();
        buffer.add("{");
        final iterator = new MapKeyValueIterator(value);
        for (k => v in iterator) {
            buffer.add(k);
            buffer.add(": ");
            buffer.add(v.toString());
            if (iterator.hasNext()) {
                buffer.add(", ");
            }
        }
        
        buffer.add("}");
        return buffer.toString();
    }
}