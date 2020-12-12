package object;

import std.lib.MemberObject;
import evaluator.Evaluator;
import object.Object.ObjectType;
import haxe.iterators.MapKeyValueIterator;
import haxe.ds.StringMap;

private class HashIterator extends MemberObject {

    public function new(evaluator:Evaluator, value:StringMap<Object>) {
        super(evaluator);

        final iterator = new MapKeyValueIterator(value);

        addFunctionMember("next", [], function(p) {
            final next = iterator.next();
            return new ArrayObj([new StringObj(next.key, evaluator), next.value], evaluator);
        });

        addFunctionMember("hasNext", [], function(p) {
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

        addFunctionMember("Iterator", [], function(p) {
            return new HashIterator(evaluator, value).getMembers();
        });

        addFunctionMember("toString", [], function(p) {
            return new StringObj(toString(), evaluator);
        });

        addFunctionMember("length", [], function(p) {
            return new NumberObj(Lambda.count(this.value), evaluator);
        });

        addFunctionMember("clone", [], function(p) {
            return clone(); 
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

        final other = cast(o, HashObj);

        for (k => v in value) {
            final oValue = other.value.get(k);

            if (oValue == null || !oValue.equals(v)) {
                return false;
            }
        }

        for (k => v in other.value) {
            final oValue = value.get(k);

            if (oValue == null || !oValue.equals(v)) {
                return false;
            }
        }

        return true;
    }

    override function clone():Object {
        final clone = new HashObj(new StringMap(), evaluator);

        for (k => v in value) {
            clone.value.set(k, v.clone());
        }

        return clone;
    }
}