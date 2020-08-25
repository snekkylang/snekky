package code;

import haxe.io.Bytes;
import haxe.io.BytesOutput;

class Code {

    public static function make(op:OpCode, operands:Array<Int>):Bytes {
        final instruction = new BytesOutput();
        instruction.writeByte(op.getIndex());

        for (operand in operands) {
            instruction.writeInt32(operand);
        }

        return instruction.getBytes();
    }
}