package compiler.debug;

import haxe.io.BytesInput;
import haxe.io.Bytes;
import haxe.io.BytesOutput;

class LineNumberTable {

    final table:Map<Int, {line:Int, linePos:Int}> = new Map();

    public function new() {}

    public function define(byteIndex:Int, sourcePosition:{line:Int, linePos:Int}) {
        table.set(byteIndex, sourcePosition);
    }

    public function resolve(byteIndex:Int) {
        return table.get(byteIndex);
    }

    public function toByteCode():Bytes {
        final output = new BytesOutput();

        output.writeInt32(Lambda.count(table));
        for (byteIndex => position in table) {
            output.writeInt32(byteIndex);
            output.writeInt32(position.line);
            output.writeInt32(position.linePos);
        }

        return output.getBytes();
    }

    public function fromByteCode(byteCode:BytesInput):LineNumberTable {
        final tableSize = byteCode.readInt32();

        for (_ in 0...tableSize) {
            final byteIndex = byteCode.readInt32();
            final line = byteCode.readInt32();
            final linePos = byteCode.readInt32();

            table.set(byteIndex, {line:line, linePos: linePos});
        }

        return this;
    }
}