package object;

import std.lib.MemberObject;
import vm.VirtualMachine;
import object.Object.ObjectType;
import haxe.iterators.ArrayIterator as HaxeArrayIterator;

private class ArrayIterator extends MemberObject {

    public function new(vm:VirtualMachine, value:Array<Object>) {
        super(vm);

        var index = -1;

        addFunctionMember("next", [], function(p) {
            index++;
            return new ArrayObj([value[index], new NumberObj(index, vm)], vm);
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

        addFunctionMember("unshift", [null], function(p) {
            final v = p[0];

            value.unshift(v);

            return new NumberObj(value.length, vm);
        });

        addFunctionMember("shift", [], function(p) {
            return value.shift();
        });

        addFunctionMember("concat", [ObjectType.Array], function(p) {
            final o = cast(p[0], ArrayObj).value;

            return new ArrayObj(value.concat(o), vm);
        });

        addFunctionMember("every", [ObjectType.Closure], function(p) {
            final callback = cast(p[0], ClosureObj);
            
            var allPassed = true;
            for (v in value) {
                final cbResult = vm.callFunction(callback, [v]);
                if (cbResult.type != ObjectType.Boolean) {
                    error("expected callback to return boolean");
                }
                final passed = cast(cbResult, BooleanObj).value;
                if (!passed) {
                    allPassed = false;
                    break;
                }
            }

            return new BooleanObj(allPassed, vm);
        });

        addFunctionMember("fill", [null, ObjectType.Number, ObjectType.Number], function(p) {
            final v = p[0];
            final startIndex = Std.int(cast(p[1], NumberObj).value);
            final endIndex = Std.int(cast(p[2], NumberObj).value);

            for (i in 0...endIndex) {
                if (i >= startIndex) {
                    value[i] = v;
                } else if (value[i] == null) {
                    value[i] = new NullObj(vm);
                }
            }

            return this;
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
        final buffer = new StringBuf();
        buffer.add("[");
        final iterator = new HaxeArrayIterator(value);
        for (v in iterator) {
            buffer.add(v.toString());
            if (iterator.hasNext()) {
                buffer.add(", ");
            }
        }
        
        buffer.add("]");
        return buffer.toString();
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