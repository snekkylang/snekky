package std.lib.namespaces.io;

import object.NullObj;
import object.StringObj;
import object.Object.ObjectType;
import object.NumberObj;
import evaluator.Evaluator;

class Bytes extends MemberObject {

    public function new(evaluator:Evaluator, bytes:haxe.io.Bytes) {
        super(evaluator);

        addFunctionMember("getByte", [ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);

            return new NumberObj(bytes.get(pos), evaluator);
        });

        addFunctionMember("getUInt16", [ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);

            return new NumberObj(bytes.getUInt16(pos), evaluator);
        });

        addFunctionMember("getInt32", [ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);

            return new NumberObj(bytes.getInt32(pos), evaluator);
        });

        addFunctionMember("getFloat32", [ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);

            return new NumberObj(bytes.getFloat(pos), evaluator);
        });

        addFunctionMember("getFloat64", [ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);

            return new NumberObj(bytes.getDouble(pos), evaluator);
        });

        addFunctionMember("setByte", [ObjectType.Number, ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);
            final value = cast(p[1], NumberObj).value;

            bytes.set(pos, Std.int(value));

            return new NullObj(evaluator);
        });

        addFunctionMember("setUInt16", [ObjectType.Number, ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);
            final value = cast(p[1], NumberObj).value;

            bytes.setUInt16(pos, Std.int(value));

            return new NullObj(evaluator);
        });

        addFunctionMember("setInt32", [ObjectType.Number, ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);
            final value = cast(p[1], NumberObj).value;

            bytes.setInt32(pos, Std.int(value));

            return new NullObj(evaluator);
        });

        addFunctionMember("setFloat32", [ObjectType.Number, ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);
            final value = cast(p[1], NumberObj).value;

            bytes.setFloat(pos, value);

            return new NullObj(evaluator);
        });

        addFunctionMember("setFloat64", [ObjectType.Number, ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);
            final value = cast(p[1], NumberObj).value;

            bytes.setDouble(pos, value);

            return new NullObj(evaluator);
        });

        addFunctionMember("getString", [ObjectType.Number, ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);
            final len = Std.int(cast(p[1], NumberObj).value);

            return new StringObj(new UnicodeString(bytes.getString(pos, len)), evaluator);
        });

        addFunctionMember("length", [], function(p) {
            return new NumberObj(bytes.length, evaluator);
        });

        addFunctionMember("toHex", [], function(p) {
            return new StringObj(bytes.toHex(), evaluator);
        });

        addFunctionMember("toString", [], function(p) {
            return new StringObj(bytes.toString(), evaluator); 
        });
    }
}