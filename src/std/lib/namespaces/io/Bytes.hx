package std.lib.namespaces.io;

import object.NullObj;
import object.StringObj;
import object.Object.ObjectType;
import object.NumberObj;
import vm.VirtualMachine;
import haxe.io.Bytes as HaxeBytes;

class Bytes extends MemberObject {

    public final bytes:HaxeBytes;

    public function new(vm:VirtualMachine, bytes:HaxeBytes) {
        super(vm);

        this.bytes = bytes;

        addFunctionMember("getByte", [ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);

            return new NumberObj(bytes.get(pos), vm);
        });

        addFunctionMember("getUInt16", [ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);

            return new NumberObj(bytes.getUInt16(pos), vm);
        });

        addFunctionMember("getInt32", [ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);

            return new NumberObj(bytes.getInt32(pos), vm);
        });

        addFunctionMember("getFloat32", [ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);

            return new NumberObj(bytes.getFloat(pos), vm);
        });

        addFunctionMember("getFloat64", [ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);

            return new NumberObj(bytes.getDouble(pos), vm);
        });

        addFunctionMember("setByte", [ObjectType.Number, ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);
            final value = cast(p[1], NumberObj).value;

            bytes.set(pos, Std.int(value));

            return new NullObj(vm);
        });

        addFunctionMember("setUInt16", [ObjectType.Number, ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);
            final value = cast(p[1], NumberObj).value;

            bytes.setUInt16(pos, Std.int(value));

            return new NullObj(vm);
        });

        addFunctionMember("setInt32", [ObjectType.Number, ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);
            final value = cast(p[1], NumberObj).value;

            bytes.setInt32(pos, Std.int(value));

            return new NullObj(vm);
        });

        addFunctionMember("setFloat32", [ObjectType.Number, ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);
            final value = cast(p[1], NumberObj).value;

            bytes.setFloat(pos, value);

            return new NullObj(vm);
        });

        addFunctionMember("setFloat64", [ObjectType.Number, ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);
            final value = cast(p[1], NumberObj).value;

            bytes.setDouble(pos, value);

            return new NullObj(vm);
        });

        addFunctionMember("getString", [ObjectType.Number, ObjectType.Number], function(p) {
            final pos = Std.int(cast(p[0], NumberObj).value);
            final len = Std.int(cast(p[1], NumberObj).value);

            return new StringObj(new UnicodeString(bytes.getString(pos, len)), vm);
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