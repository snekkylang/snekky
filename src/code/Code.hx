package code;

import haxe.io.Bytes;
import haxe.io.BytesOutput;

class Code {

    public static function make(op:Int, operands:Array<Int>):Bytes {
        final instruction = new BytesOutput();
        instruction.writeByte(op);

        for (operand in operands) {
            instruction.writeInt32(operand);
        }

        return instruction.getBytes();
    }
}