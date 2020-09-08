package compiler.constant;

import object.ObjectOrigin;
import haxe.io.BytesInput;
import haxe.io.Bytes;
import object.objects.FunctionObj;
import object.objects.StringObj;
import object.objects.FloatObj;
import object.ObjectType;
import haxe.io.BytesOutput;
import object.objects.Object;

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
            switch (const.type) {
                case ObjectType.Float:
                    final cFloat = cast(const, FloatObj);

                    output.writeByte(ConstantType.Float);
                    output.writeDouble(cFloat.value);
                case ObjectType.String:
                    final cString = cast(const, StringObj);

                    output.writeByte(ConstantType.String);
                    output.writeInt32(cString.value.length);
                    output.writeString(cString.value);
                case ObjectType.Function:
                    final cFunction = cast(const, FunctionObj);

                    output.writeByte(ConstantType.Function);
                    output.writeInt32(cFunction.index);
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
                    pool.push(new FloatObj(value));
                case ConstantType.String:
                    final length = byteCode.readInt32();
                    final value = byteCode.readString(length);
                    pool.push(new StringObj(value));
                case ConstantType.Function:
                    final index = byteCode.readInt32();
                    pool.push(new FunctionObj(index, ObjectOrigin.UserDefined));
                default:
            }    
        }

        return pool;
    }
}