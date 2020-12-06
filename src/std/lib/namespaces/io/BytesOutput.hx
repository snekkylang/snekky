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

        addFunctionMember("setBigEndian", [ObjectType.Boolean], function(p) {
            final bigEndian = cast(p[0], BooleanObj).value;

            bytes.bigEndian = bigEndian;

            return new NullObj(evaluator);
        });

        addFunctionMember("writeByte", [ObjectType.Number], function(p) {
            final value = Std.int(cast(p[0], NumberObj).value);
            
            bytes.writeByte(Std.int(value));

            return new NullObj(evaluator);
        });

        addFunctionMember("writeInt8", [ObjectType.Number], function(p) {
            final value = Std.int(cast(p[0], NumberObj).value);
            
            bytes.writeInt8(Std.int(value));

            return new NullObj(evaluator);
        });

        addFunctionMember("writeInt16", [ObjectType.Number], function(p) {
            final value = Std.int(cast(p[0], NumberObj).value);
            
            bytes.writeInt16(Std.int(value));

            return new NullObj(evaluator);
        });

        addFunctionMember("writeUInt16", [ObjectType.Number], function(p) {
            final value = Std.int(cast(p[0], NumberObj).value);
            
            bytes.writeUInt16(Std.int(value));

            return new NullObj(evaluator);
        });

        addFunctionMember("writeInt24", [ObjectType.Number], function(p) {
            final value = Std.int(cast(p[0], NumberObj).value);
            
            bytes.writeInt24(Std.int(value));

            return new NullObj(evaluator);
        });

        addFunctionMember("writeUInt24", [ObjectType.Number], function(p) {
            final value = Std.int(cast(p[0], NumberObj).value);
            
            bytes.writeUInt24(Std.int(value));

            return new NullObj(evaluator);
        });

        addFunctionMember("writeInt32", [ObjectType.Number], function(p) {
            final value = Std.int(cast(p[0], NumberObj).value);
            
            bytes.writeInt32(Std.int(value));

            return new NullObj(evaluator);
        });

        addFunctionMember("writeFloat32", [ObjectType.Number], function(p) {
            final value = Std.int(cast(p[0], NumberObj).value);
            
            bytes.writeFloat(value);

            return new NullObj(evaluator);
        });
        
        addFunctionMember("writeFloat64", [ObjectType.Number], function(p) {
            final value = Std.int(cast(p[0], NumberObj).value);
            
            bytes.writeDouble(value);

            return new NullObj(evaluator);
        });


        addFunctionMember("writeString", [ObjectType.String], function(p) {
            final value = cast(p[0], StringObj).value;

            bytes.writeString(value);

            return new NullObj(evaluator);
        });

        addFunctionMember("writeHex", [ObjectType.String], function(p) {
            final value = cast(p[0], StringObj).value;

            bytes.write(haxe.io.Bytes.ofHex(value));

            return new NullObj(evaluator);
        });
        
        addFunctionMember("length", [], function(p) {
            return new NumberObj(bytes.length, evaluator);
        });

        addFunctionMember("getBytes", [], function(p) {
            return new Bytes(evaluator, bytes.getBytes()).getMembers();
        });
    }  
}