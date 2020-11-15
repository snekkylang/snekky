package std.lib.namespaces.io;

import object.BooleanObj;
import object.NullObj;
import object.StringObj;
import object.NumberObj;
import evaluator.Evaluator;
import object.Object.ObjectType;

class BytesOutput extends MemberObject {

    public function new(evaluator:Evaluator, bytes:haxe.io.BytesOutput) {
        super(evaluator);

        addFunctionMember("setBigEndian", 1, function(p) {
            assertParameterType(p[0], ObjectType.Boolean);
            final bigEndian = cast(p[0], BooleanObj).value;

            bytes.bigEndian = bigEndian;

            return new NullObj(evaluator);
        });

        addFunctionMember("writeByte", 1, function(p) {
            assertParameterType(p[0], ObjectType.Number);
            final value = Std.int(cast(p[0], NumberObj).value);
            
            bytes.writeByte(Std.int(value));

            return new NullObj(evaluator);
        });

        addFunctionMember("writeInt8", 1, function(p) {
            assertParameterType(p[0], ObjectType.Number);
            final value = Std.int(cast(p[0], NumberObj).value);
            
            bytes.writeInt8(Std.int(value));

            return new NullObj(evaluator);
        });

        addFunctionMember("writeInt16", 1, function(p) {
            assertParameterType(p[0], ObjectType.Number);
            final value = Std.int(cast(p[0], NumberObj).value);
            
            bytes.writeInt16(Std.int(value));

            return new NullObj(evaluator);
        });

        addFunctionMember("writeUInt16", 1, function(p) {
            assertParameterType(p[0], ObjectType.Number);
            final value = Std.int(cast(p[0], NumberObj).value);
            
            bytes.writeUInt16(Std.int(value));

            return new NullObj(evaluator);
        });

        addFunctionMember("writeInt24", 1, function(p) {
            assertParameterType(p[0], ObjectType.Number);
            final value = Std.int(cast(p[0], NumberObj).value);
            
            bytes.writeInt24(Std.int(value));

            return new NullObj(evaluator);
        });

        addFunctionMember("writeUInt24", 1, function(p) {
            assertParameterType(p[0], ObjectType.Number);
            final value = Std.int(cast(p[0], NumberObj).value);
            
            bytes.writeUInt24(Std.int(value));

            return new NullObj(evaluator);
        });

        addFunctionMember("writeInt32", 1, function(p) {
            assertParameterType(p[0], ObjectType.Number);
            final value = Std.int(cast(p[0], NumberObj).value);
            
            bytes.writeInt32(Std.int(value));

            return new NullObj(evaluator);
        });

        addFunctionMember("writeFloat32", 1, function(p) {
            assertParameterType(p[0], ObjectType.Number);
            final value = Std.int(cast(p[0], NumberObj).value);
            
            bytes.writeFloat(value);

            return new NullObj(evaluator);
        });
        
        addFunctionMember("writeFloat64", 1, function(p) {
            assertParameterType(p[0], ObjectType.Number);
            final value = Std.int(cast(p[0], NumberObj).value);
            
            bytes.writeDouble(value);

            return new NullObj(evaluator);
        });


        addFunctionMember("writeString", 1, function(p) {
            assertParameterType(p[0], ObjectType.String);
            final value = cast(p[0], StringObj).value;

            bytes.writeString(value);

            return new NullObj(evaluator);
        });

        addFunctionMember("writeHex", 1, function(p) {
            assertParameterType(p[0], ObjectType.String);
            final value = cast(p[0], StringObj).value;

            bytes.write(haxe.io.Bytes.ofHex(value));

            return new NullObj(evaluator);
        });
        
        addFunctionMember("length", 0, function(p) {
            return new NumberObj(bytes.length, evaluator);
        });

        addFunctionMember("getBytes", 0, function(p) {
            return new Bytes(evaluator, bytes.getBytes()).getMembers();
        });
    }  
}