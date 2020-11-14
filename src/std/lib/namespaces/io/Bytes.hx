package std.lib.namespaces.io;

import object.NullObj;
import object.StringObj;
import object.Object.ObjectType;
import object.NumberObj;
import evaluator.Evaluator;

class Bytes extends MemberObject {

    public function new(evaluator:Evaluator, bytes:haxe.io.Bytes) {
        super(evaluator);

        addFunctionMember("get", 1, function(p) {
            assertParameterType(p[0], ObjectType.Number);
            final pos = Std.int(cast(p[0], NumberObj).value);

            return new NumberObj(bytes.get(pos), evaluator);
        });

        addFunctionMember("getNumber", 2, function(p) {
            assertParameterType(p[0], ObjectType.Number);
            final pos = Std.int(cast(p[0], NumberObj).value);
            
            assertParameterType(p[1], ObjectType.String);
            final type = cast(p[1], StringObj).value;

            return switch (type) {
                case "byte": new NumberObj(bytes.get(pos), evaluator);
                case "uint16": new NumberObj(bytes.getUInt16(pos), evaluator);
                case "int32": new NumberObj(bytes.getInt32(pos), evaluator);
                case "float32": new NumberObj(bytes.getFloat(pos), evaluator);
                case "float64": new NumberObj(bytes.getDouble(pos), evaluator);
                default: 
                    error('unsupported data type `$type`');
                    null;
            }
        });

        addFunctionMember("setNumber", 3, function(p) {
            assertParameterType(p[0], ObjectType.Number);
            final pos = Std.int(cast(p[0], NumberObj).value);

            assertParameterType(p[1], ObjectType.Number);
            final value = cast(p[1], NumberObj).value;
            
            assertParameterType(p[2], ObjectType.String);
            final type = cast(p[2], StringObj).value;

            switch (type) {
                case "byte": bytes.set(pos, Std.int(value));
                case "uint16": bytes.setUInt16(pos, Std.int(value));
                case "int32": bytes.setInt32(pos, Std.int(value));
                case "float32": bytes.setFloat(pos, value);
                case "float64": bytes.setDouble(pos, value);
                default: error('unsupported data type `$type`');
            }

            addFunctionMember("getString", 2, function(p) {
                assertParameterType(p[0], ObjectType.Number);
                final pos = Std.int(cast(p[0], NumberObj).value);

                assertParameterType(p[1], ObjectType.Number);
                final len = Std.int(cast(p[1], NumberObj).value);

                return new StringObj(bytes.getString(pos, len), evaluator);
            });

            return new NullObj(evaluator);
        });

        addFunctionMember("toString", 0, function(p) {
            return new StringObj(bytes.toString(), evaluator);
        });

        addFunctionMember("toHex", 0, function(p) {
            return new StringObj(bytes.toHex(), evaluator);
        });
    }
}