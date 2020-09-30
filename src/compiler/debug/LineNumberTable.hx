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
        final tableBytes = new BytesOutput();

        for (byteIndex => position in table) {
            tableBytes.writeInt32(byteIndex);
            tableBytes.writeInt32(position.line);
            tableBytes.writeInt32(position.linePos);
        }

        final output = new BytesOutput();
        output.writeInt32(tableBytes.length);
        output.write(tableBytes.getBytes());

        return output.getBytes();
    }

    public function fromByteCode(byteCode:BytesInput):LineNumberTable {
        final tableSize = byteCode.readInt32();
        final startPosition = byteCode.position;

        while(byteCode.position < startPosition + tableSize) {
            final byteIndex = byteCode.readInt32();
            final line = byteCode.readInt32();
            final linePos = byteCode.readInt32();

            table.set(byteIndex, {line:line, linePos: linePos});
        }

        return this;
    }
}