package object;

import std.lib.MemberObject;
import vm.VirtualMachine;
import object.Object.ObjectType;
import haxe.iterators.MapKeyValueIterator;
import haxe.ds.StringMap;

private class HashIterator extends MemberObject {

    public function new(vm:VirtualMachine, value:StringMap<Object>) {
        super(vm);

        final iterator = new MapKeyValueIterator(value);

        addFunctionMember("next", [], function(p) {
            final next = iterator.next();
            return new ArrayObj([next.value, new StringObj(next.key, vm)], vm);
        });

        addFunctionMember("hasNext", [], function(p) {
            return new BooleanObj(iterator.hasNext(), vm);
        });
    }
}

class HashObj extends Object {
    
    public final value:StringMap<Object>;

    public function new(value:StringMap<Object>, vm:VirtualMachine) {
        super(ObjectType.Hash, vm);

        this.value = value;

        if (vm == null) {
            return;
        }

        addFunctionMember("Iterator", [], function(p) {
            return new HashIterator(vm, value).getMembers();
        });

        addFunctionMember("toString", [], function(p) {
            return new StringObj(toString(), vm);
        });

        addFunctionMember("length", [], function(p) {
            return new NumberObj(Lambda.count(this.value), vm);
        });

        addFunctionMember("clone", [], function(p) {
            return clone(); 
        });
    }

    inline public function set(name:String, v:Object) {
        value.set(name, v);
    }

    inline public function get(name:String) {
        final v = value.get(name);

        return if (v == null) {
            new NullObj(vm);
        } else {
            v;
        };
    }

    inline public function exists(name):Bool {
        return value.exists(name);
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
        final clone = new HashObj(new StringMap(), vm);

        for (k => v in value) {
            clone.value.set(k, v.clone());
        }

        return clone;
    }
}