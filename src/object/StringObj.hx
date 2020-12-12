package object;

import std.lib.namespaces.io.Bytes;
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

        addFunctionMember("toString", [], function(p) {
            return new StringObj(toString(), evaluator);
        });

        addFunctionMember("length", [], function(p) {
            return new NumberObj(this.value.length, evaluator);
        });

        addFunctionMember("charAt", [ObjectType.Number], function(p) {
            final index = Std.int(cast(p[0], NumberObj).value);
            final v = this.value.charAt(index);
            return new StringObj(v, evaluator);
        });

        addFunctionMember("charCodeAt", [ObjectType.Number], function(p) {
            final index = Std.int(cast(p[0], NumberObj).value);
            final v = this.value.charCodeAt(index);
            return v == null ? new NullObj(evaluator) : new NumberObj(v, evaluator);
        });

        addFunctionMember("split", [ObjectType.String], function(p) {
            final separator = cast(p[0], StringObj).value;
            final arr:Array<Object> = [];
            for (v in this.value.split(separator)) {
                arr.push(new StringObj(v, evaluator));
            }
            return new ArrayObj(arr, evaluator);
        });

        addFunctionMember("contains", [ObjectType.String], function(p) {
            final sub = cast(p[0], StringObj).value;

            return new BooleanObj(StringTools.contains(value, sub), evaluator);
        });

        addFunctionMember("indexOf", [ObjectType.String, ObjectType.Number], function(p) {
            final sub = cast(p[0], StringObj).value;
            final start = Std.int(cast(p[1], NumberObj).value);

            return new NumberObj(value.indexOf(sub, start), evaluator);
        });

        addFunctionMember("substr", [ObjectType.Number, ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);
            final len = Std.int(cast(p[1], NumberObj).value);

            return new StringObj(value.substr(pos, len), evaluator);
        });

        addFunctionMember("substring", [ObjectType.Number, ObjectType.Number], function(p) {
            final start = Std.int(cast(p[0], NumberObj).value);
            final end = Std.int(cast(p[1], NumberObj).value);

            return new StringObj(value.substring(start, end), evaluator);
        });

        addFunctionMember("replace", [ObjectType.String, ObjectType.String], function(p) {
            final sub = cast(p[0], StringObj).value;
            final by = cast(p[1], StringObj).value;

            return new StringObj(StringTools.replace(value, sub, by), evaluator);
        });

        addFunctionMember("toBytes", [], function(p) {
            return new Bytes(evaluator, haxe.io.Bytes.ofHex(value)).getMembers();
        });

        addFunctionMember("toHex", [], function(p) {
            return new StringObj(haxe.io.Bytes.ofString(value).toHex(), evaluator);
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
        return new StringObj(value, evaluator);
    }
}