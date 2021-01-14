package std.lib.namespaces.io;

import object.BooleanObj;
import object.NullObj;
import object.StringObj;
import object.NumberObj;
import vm.VirtualMachine;
import object.Object.ObjectType;

class BytesOutput extends MemberObject {

    public function new(vm:VirtualMachine, bytes:haxe.io.BytesOutput) {
        super(vm);

        addFunctionMember("setBigEndian", [ObjectType.Boolean], function(p) {
            final bigEndian = cast(p[0], BooleanObj).value;

            bytes.bigEndian = bigEndian;

            return new NullObj(vm);
        });

        addFunctionMember("writeByte", [ObjectType.Number], function(p) {
            final value = Std.int(cast(p[0], NumberObj).value);
            
            bytes.writeByte(Std.int(value));

            return new NullObj(vm);
        });

        addFunctionMember("writeInt8", [ObjectType.Number], function(p) {
            final value = Std.int(cast(p[0], NumberObj).value);
            
            bytes.writeInt8(Std.int(value));

            return new NullObj(vm);
        });

        addFunctionMember("writeInt16", [ObjectType.Number], function(p) {
            final value = Std.int(cast(p[0], NumberObj).value);
            
            bytes.writeInt16(Std.int(value));

            return new NullObj(vm);
        });

        addFunctionMember("writeUInt16", [ObjectType.Number], function(p) {
            final value = Std.int(cast(p[0], NumberObj).value);
            
            bytes.writeUInt16(Std.int(value));

            return new NullObj(vm);
        });

        addFunctionMember("writeInt24", [ObjectType.Number], function(p) {
            final value = Std.int(cast(p[0], NumberObj).value);
            
            bytes.writeInt24(Std.int(value));

            return new NullObj(vm);
        });

        addFunctionMember("writeUInt24", [ObjectType.Number], function(p) {
            final value = Std.int(cast(p[0], NumberObj).value);
            
            bytes.writeUInt24(Std.int(value));

            return new NullObj(vm);
        });

        addFunctionMember("writeInt32", [ObjectType.Number], function(p) {
            final value = Std.int(cast(p[0], NumberObj).value);
            
            bytes.writeInt32(Std.int(value));

            return new NullObj(vm);
        });

        addFunctionMember("writeFloat32", [ObjectType.Number], function(p) {
            final value = Std.int(cast(p[0], NumberObj).value);
            
            bytes.writeFloat(value);

            return new NullObj(vm);
        });
        
        addFunctionMember("writeFloat64", [ObjectType.Number], function(p) {
            final value = Std.int(cast(p[0], NumberObj).value);
            
            bytes.writeDouble(value);

            return new NullObj(vm);
        });


        addFunctionMember("writeString", [ObjectType.String], function(p) {
            final value = cast(p[0], StringObj).value;

            bytes.writeString(value);

            return new NullObj(vm);
        });

        addFunctionMember("writeHex", [ObjectType.String], function(p) {
            final value = cast(p[0], StringObj).value;

            bytes.write(haxe.io.Bytes.ofHex(value));

            return new NullObj(vm);
        });
        
        addFunctionMember("length", [], function(p) {
            return new NumberObj(bytes.length, vm);
        });

        addFunctionMember("getBytes", [], function(p) {
            return new Bytes(vm, bytes.getBytes()).getMembers();
        });
    }  
}