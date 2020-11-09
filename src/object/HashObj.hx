package object;

import std.lib.MemberObject;
import evaluator.Evaluator;
import object.Object.ObjectType;
import haxe.iterators.MapKeyValueIterator;
import haxe.ds.StringMap;

using equals.Equal;

private class HashIterator extends MemberObject {

    public function new(evaluator:Evaluator, value:StringMap<Object>) {
        super(evaluator);

        final iterator = new MapKeyValueIterator(value);

        addFunctionMember("next", 0, function(p) {
            final next = iterator.next();
            return new ArrayObj([new StringObj(next.key, evaluator), next.value], evaluator);
        });

        addFunctionMember("hasNext", 0, function(p) {
            return new BooleanObj(iterator.hasNext(), evaluator);
        });
    }
}

class HashObj extends Object {
    
    public final value:StringMap<Object>;

    public function new(value:StringMap<Object>, evaluator:Evaluator) {
        super(ObjectType.Hash, evaluator);

        this.value = value;

        if (evaluator == null) {
            return;
        }

        addFunctionMember("Iterator", 0, function(p) {
            return new HashIterator(evaluator, value).getMembers();
        });

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

    override function equals(o:Object):Bool {
        if (o.type != ObjectType.Hash) {
            return false;
        }

        return value.equals(cast(o, HashObj).value);
    }
}