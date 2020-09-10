package compiler.constant;

import object.Object;
import object.ObjectOrigin;
import haxe.io.BytesInput;
import haxe.io.Bytes;
import haxe.io.BytesOutput;

class ConstantPool {

    final constants:Array<Object> = [];

    public function new() { }

    public function addConstant(obj:Object):Int {
        return constants.push(obj);
    }

    public function getSize():Int {
        return constants.length;
    }

    public function toByteCode():Bytes {
        final output = new BytesOutput();

        output.writeInt32(constants.length);
        for (const in constants) {
            switch (const) {
                case Object.Float(value):
                    output.writeByte(ConstantType.Float);
                    output.writeDouble(value);
                case Object.String(value):
                    output.writeByte(ConstantType.String);
                    output.writeInt32(Bytes.ofString(value).length);
                    output.writeString(value);
                case Object.Function(index, origin):
                    output.writeByte(ConstantType.Function);
                    output.writeInt32(index);
                default:
            }
        }

        return output.getBytes();
    }

    public static function fromByteCode(byteCode:BytesInput):Array<Object> {
        final pool:Array<Object> = [];
        final poolSize = byteCode.readInt32();

        for (_ in 0...poolSize) {
            final type = byteCode.readByte();

            switch (type) {
                case ConstantType.Float:
                    final value = byteCode.readDouble();
                    pool.push(Object.Float(value));
                case ConstantType.String:
                    final length = byteCode.readInt32();
                    final value = byteCode.readString(length);
                    pool.push(Object.String(value));
                case ConstantType.Function:
                    final index = byteCode.readInt32();
                    pool.push(Object.Function(index, ObjectOrigin.UserDefined));
                default:
            }    
        }

        return pool;
    }
}