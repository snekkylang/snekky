package std.lib.namespaces.io;

import object.NullObj;
import object.StringObj;
import object.Object.ObjectType;
import object.NumberObj;
import vm.VirtualMachine;

class Bytes extends MemberObject {

    public function new(vm:VirtualMachine, bytes:haxe.io.Bytes) {
        super(vm);

        addFunctionMember("getByte", [ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);

            final value = bytes.get(pos);
            if (value == null) {
                error('index $pos out of bounds (length: ${bytes.length})');
                return null;
            }

            return new NumberObj(bytes.get(pos), vm);
        });

        addFunctionMember("getUInt16", [ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);

            return try {
                new NumberObj(bytes.getUInt16(pos), vm);
            } catch (err) {
                error('index $pos out of bounds (length: ${bytes.length})');
                null;
            }
        });

        addFunctionMember("getInt32", [ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);

            return try {
                new NumberObj(bytes.getInt32(pos), vm);
            } catch (err) {
                error('index $pos out of bounds (length: ${bytes.length})');
                null;
            }
        });

        addFunctionMember("getFloat32", [ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);

            return try {
                new NumberObj(bytes.getFloat(pos), vm);
            } catch (err) {
                error('index $pos out of bounds (length: ${bytes.length})');
                null;
            }
        });

        addFunctionMember("getFloat64", [ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);

            return try {
                new NumberObj(bytes.getDouble(pos), vm);
            } catch (err) {
                error('index $pos out of bounds (length: ${bytes.length})');
                null;
            }
        });

        addFunctionMember("setByte", [ObjectType.Number, ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);
            final value = cast(p[1], NumberObj).value;

            if (pos >= bytes.length) {
                error('index $pos out of bounds (length: ${bytes.length})');
                return null;
            }

            bytes.set(pos, Std.int(value));

            return new NullObj(vm);
        });

        addFunctionMember("setUInt16", [ObjectType.Number, ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);
            final value = cast(p[1], NumberObj).value;

            try {
                bytes.setUInt16(pos, Std.int(value));
            } catch (err) {
                error('index $pos out of bounds (length: ${bytes.length})');
                return null;
            }

            return new NullObj(vm);
        });

        addFunctionMember("setInt32", [ObjectType.Number, ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);
            final value = cast(p[1], NumberObj).value;

            try {
                bytes.setInt32(pos, Std.int(value));
            } catch (err) {
                error('index $pos out of bounds (length: ${bytes.length})');
                return null;
            }

            return new NullObj(vm);
        });

        addFunctionMember("setFloat32", [ObjectType.Number, ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);
            final value = cast(p[1], NumberObj).value;

            try {
                bytes.setFloat(pos, value);
            } catch (err) {
                error('index $pos out of bounds (length: ${bytes.length})');
                return null;
            }


            return new NullObj(vm);
        });

        addFunctionMember("setFloat64", [ObjectType.Number, ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);
            final value = cast(p[1], NumberObj).value;

            try {
                bytes.setDouble(pos, value);
            } catch (err) {
                error('index $pos out of bounds (length: ${bytes.length})');
                return null;
            }

            return new NullObj(vm);
        });

        addFunctionMember("getString", [ObjectType.Number, ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);
            final len = Std.int(cast(p[1], NumberObj).value);

            return try {
                new StringObj(new UnicodeString(bytes.getString(pos, len)), vm);
            } catch (err) {
                error('index $pos out of bounds (length: ${bytes.length})');
                null; 
            }
        });

        addFunctionMember("length", [], function(p) {
            return new NumberObj(bytes.length, vm);
        });

        addFunctionMember("toHex", [], function(p) {
            return new StringObj(bytes.toHex(), vm);
        });

        addFunctionMember("toString", [], function(p) {
            return new StringObj(bytes.toString(), vm); 
        });
    }
}