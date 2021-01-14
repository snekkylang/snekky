package object;

import std.lib.namespaces.io.Bytes;
import vm.VirtualMachine;
import object.Object.ObjectType;

class StringObj extends Object {

    public final value:String;

    public function new(value:String, vm:VirtualMachine) {
        super(ObjectType.String, vm);

        this.value = value;

        if (vm == null) {
            return;
        }

        addFunctionMember("toString", [], function(p) {
            return new StringObj(toString(), vm);
        });

        addFunctionMember("length", [], function(p) {
            return new NumberObj(this.value.length, vm);
        });

        addFunctionMember("charAt", [ObjectType.Number], function(p) {
            final index = Std.int(cast(p[0], NumberObj).value);
            final v = this.value.charAt(index);
            return new StringObj(v, vm);
        });

        addFunctionMember("charCodeAt", [ObjectType.Number], function(p) {
            final index = Std.int(cast(p[0], NumberObj).value);
            final v = this.value.charCodeAt(index);
            return v == null ? new NullObj(vm) : new NumberObj(v, vm);
        });

        addFunctionMember("split", [ObjectType.String], function(p) {
            final separator = cast(p[0], StringObj).value;
            final arr:Array<Object> = [];
            for (v in this.value.split(separator)) {
                arr.push(new StringObj(v, vm));
            }
            return new ArrayObj(arr, vm);
        });

        addFunctionMember("contains", [ObjectType.String], function(p) {
            final sub = cast(p[0], StringObj).value;

            return new BooleanObj(StringTools.contains(value, sub), vm);
        });

        addFunctionMember("indexOf", [ObjectType.String, ObjectType.Number], function(p) {
            final sub = cast(p[0], StringObj).value;
            final start = Std.int(cast(p[1], NumberObj).value);

            return new NumberObj(value.indexOf(sub, start), vm);
        });

        addFunctionMember("substr", [ObjectType.Number, ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);
            final len = Std.int(cast(p[1], NumberObj).value);

            return new StringObj(value.substr(pos, len), vm);
        });

        addFunctionMember("substring", [ObjectType.Number, ObjectType.Number], function(p) {
            final start = Std.int(cast(p[0], NumberObj).value);
            final end = Std.int(cast(p[1], NumberObj).value);

            return new StringObj(value.substring(start, end), vm);
        });

        addFunctionMember("replace", [ObjectType.String, ObjectType.String], function(p) {
            final sub = cast(p[0], StringObj).value;
            final by = cast(p[1], StringObj).value;

            return new StringObj(StringTools.replace(value, sub, by), vm);
        });

        addFunctionMember("toBytes", [], function(p) {
            return new Bytes(vm, haxe.io.Bytes.ofHex(value)).getMembers();
        });

        addFunctionMember("toHex", [], function(p) {
            return new StringObj(haxe.io.Bytes.ofString(value).toHex(), vm);
        });
    }

    override function toString():String {
        return value;
    }

    override function equals(o:Object):Bool {
        if (o.type != ObjectType.String) {
            return false;
        }

        return cast(o, StringObj).value == value;
    }

    override function clone():Object {
        return new StringObj(value, vm);
    }
}