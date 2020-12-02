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
            return new StringObj(v, evaluator);
        });

        addFunctionMember("charCodeAt", 1, function(p) {
            assertParameterType(p[0], ObjectType.Number);
            final index = Std.int(cast(p[0], NumberObj).value);
            final v = this.value.charCodeAt(index);
            return v == null ? new NullObj(evaluator) : new NumberObj(v, evaluator);
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

        addFunctionMember("contains", 1, function(p) {
            assertParameterType(p[0], ObjectType.String);
            final sub = cast(p[0], StringObj).value;

            return new BooleanObj(StringTools.contains(value, sub), evaluator);
        });

        addFunctionMember("indexOf", 2, function(p) {
            assertParameterType(p[0], ObjectType.String);
            final sub = cast(p[0], StringObj).value;

            assertParameterType(p[1], ObjectType.Number);
            final start = Std.int(cast(p[1], NumberObj).value);

            return new NumberObj(value.indexOf(sub, start), evaluator);
        });

        addFunctionMember("substr", 2, function(p) {
            assertParameterType(p[0], ObjectType.Number);
            final pos = Std.int(cast(p[0], NumberObj).value);

            assertParameterType(p[1], ObjectType.Number);
            final len = Std.int(cast(p[1], NumberObj).value);

            return new StringObj(value.substr(pos, len), evaluator);
        });

        addFunctionMember("substring", 2, function(p) {
            assertParameterType(p[0], ObjectType.Number);
            final start = Std.int(cast(p[0], NumberObj).value);

            assertParameterType(p[1], ObjectType.Number);
            final end = Std.int(cast(p[1], NumberObj).value);

            return new StringObj(value.substring(start, end), evaluator);
        });

        addFunctionMember("replace", 2, function(p) {
            assertParameterType(p[0], ObjectType.String);
            final sub = cast(p[0], StringObj).value;

            assertParameterType(p[1], ObjectType.String);
            final by = cast(p[1], StringObj).value;

            return new StringObj(StringTools.replace(value, sub, by), evaluator);
        });

        addFunctionMember("toBytes", 0, function(p) {
            return new Bytes(evaluator, haxe.io.Bytes.ofHex(value)).getMembers();
        });

        addFunctionMember("toHex", 0, function(p) {
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
}