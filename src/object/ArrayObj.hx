package object;

import std.lib.MemberObject;
import vm.VirtualMachine;
import object.Object.ObjectType;

private class ArrayIterator extends MemberObject {

    public function new(vm:VirtualMachine, value:Array<Object>) {
        super(vm);

        var index = -1;

        addFunctionMember("next", [], function(p) {
            index++;
            return value[index];
        });

        addFunctionMember("hasNext", [], function(p) {
            return new BooleanObj(index < value.length - 1, vm);
        });
    }
}

class ArrayObj extends Object {

    public final value:Array<Object>;

    public function new(value:Array<Object>, vm:VirtualMachine) {
        super(ObjectType.Array, vm);

        this.value = value;

        if (vm == null) {
            return;
        }

        addFunctionMember("Iterator", [], function(p) {
            return new ArrayIterator(vm, value).getMembers();
        });

        addFunctionMember("length", [], function(p) {
            return new NumberObj(this.value.length, vm);
        });

        addFunctionMember("toString", [], function(p) {
            return new StringObj(this.value.toString(), vm);
        });

        addFunctionMember("push", [null], function(p) {
            this.value.push(p[0]);

            return new NumberObj(this.value.length, vm);
        });

        addFunctionMember("pop", [], function(p) {
            return this.value.pop();
        });

        addFunctionMember("join", [ObjectType.String], function(p) {
            final seperator = cast(p[0], StringObj).value;

            return new StringObj(value.join(seperator), vm);
        });

        addFunctionMember("contains", [null], function(p) {
            for (v in value) {
                if (v.equals(p[0])) {
                    return new BooleanObj(true, vm);
                }
            }

            return new BooleanObj(false, vm);
        });

        addFunctionMember("map", [ObjectType.Closure], function(p) {
            final callback = cast(p[0], ClosureObj);
            final newArray:Array<Object> = [];

            for (v in value) {
                newArray.push(vm.callFunction(callback, [v]));
            }

            return new ArrayObj(newArray, vm);
        });

        addFunctionMember("filter", [ObjectType.Closure], function(p) {
            final callback = cast(p[0], ClosureObj);
            final newArray:Array<Object> = [];
            
            for (v in value) {
                final cbResult = vm.callFunction(callback, [v]);
                if (cbResult.type != ObjectType.Boolean) {
                    error("expected callback to return boolean");
                }
                final include = cast(cbResult, BooleanObj).value;
                if (include) {
                    newArray.push(v);
                }
            }

            return new ArrayObj(newArray, vm);
        });

        addFunctionMember("forEach", [ObjectType.Closure], function(p) {
            final callback = cast(p[0], ClosureObj);
            
            for (v in value) {
                vm.callFunction(callback, [v]);
            }

            return new ArrayObj(value, vm);
        });

        addFunctionMember("sort", [ObjectType.Closure], function(p) {
            final callback = cast(p[0], ClosureObj);

            value.sort(function(v1, v2) {
                final cbResult = vm.callFunction(callback, [v1, v2]);
                if (cbResult.type != ObjectType.Number) {
                    error("expected callback to return number");
                }
                final pos = Std.int(cast(cbResult, NumberObj).value);

                return pos;
            });

            return new NullObj(vm);
        });

        addFunctionMember("clone", [], function(p) {
            return clone(); 
        });
    }

    override function toString():String {
        return value.map(o -> o.toString()).toString(); 
    }

    override function equals(o:Object):Bool {
        if (o.type != ObjectType.Array) {
            return false;
        }

        final other = cast(o, ArrayObj);
        if (other.value.length != value.length) {
            return false;
        }

        for (i => v in value) {
            if (!other.value[i].equals(v)) {
                return false;
            }
        }

        return true;
    }

    override function clone():Object {
        final clone = new ArrayObj([], vm);

        for (i => v in value) {
            clone.value[i] = v.clone();
        }

        return clone;
    }
}