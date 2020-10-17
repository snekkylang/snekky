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
        final constantsBytes = new BytesOutput();

        for (const in constants) {
            switch (const) {
                case Object.Number(value):
                    constantsBytes.writeByte(ConstantType.Float);
                    constantsBytes.writeDouble(value);
                case Object.String(value):
                    constantsBytes.writeByte(ConstantType.String);
                    constantsBytes.writeInt32(Bytes.ofString(value).length);
                    constantsBytes.writeString(value);
                case Object.UserFunction(position, parametersCount):
                    constantsBytes.writeByte(ConstantType.UserFunction);
                    constantsBytes.writeInt32(position);
                    constantsBytes.writeInt16(parametersCount);
                case Object.Null:
                    constantsBytes.writeByte(ConstantType.Null);
                default:
            }
        }

        final output = new BytesOutput();
        output.writeInt32(constantsBytes.length);
        output.write(constantsBytes.getBytes());

        return output.getBytes();
    }

    public static function fromByteCode(byteCode:BytesInput):Array<Object> {
        final pool:Array<Object> = [];
        final poolSize = byteCode.readInt32();
        final startPosition = byteCode.position;

        while (byteCode.position < startPosition + poolSize) {
            final type = byteCode.readByte();

            switch (type) {
                case ConstantType.Float:
                    final value = byteCode.readDouble();
                    pool.push(Object.Number(value));
                case ConstantType.String:
                    final length = byteCode.readInt32();
                    final value = byteCode.readString(length);
                    pool.push(Object.String(value));
                case ConstantType.UserFunction:
                    final position = byteCode.readInt32();
                    final parametersCount = byteCode.readInt16();
                    pool.push(Object.UserFunction(position, parametersCount));
                case ConstantType.Null:
                    pool.push(Object.Null);
                default:
            }    
        }

        return pool;
    }
}