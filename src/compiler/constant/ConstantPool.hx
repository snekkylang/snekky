package compiler.constant;

import object.Object;
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
                case Object.UserFunction(position):
                    output.writeByte(ConstantType.UserFunction);
                    output.writeInt32(position);
                case Object.Null:
                    output.writeByte(ConstantType.Null);
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
                case ConstantType.UserFunction:
                    final position = byteCode.readInt32();
                    pool.push(Object.UserFunction(position));
                case ConstantType.Null:
                    pool.push(Object.Null);
                default:
            }    
        }

        return pool;
    }
}