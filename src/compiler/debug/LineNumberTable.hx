package compiler.debug;

import haxe.io.BytesInput;
import haxe.io.Bytes;
import haxe.io.BytesOutput;

private typedef Position = {line:Int, linePos:Int}; 

class LineNumberTable {

    final table:Map<Int, Position> = new Map();

    public function new() {}

    public function define(byteIndex:Int, sourcePosition:{line:Int, linePos:Int}) {
        table.set(byteIndex, sourcePosition);
    }

    public function resolve(byteIndex:Int):Position {
        if (byteIndex < 0) {
            return null;
        }

        final position = table.get(byteIndex);

        return if (position != null) {
            position;
        } else {
            resolve(byteIndex - 1);
        }
    }

    public function concat(other:LineNumberTable) {
        for (k => v in other.table) {
            table.set(k, v);
        }
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

        while (byteCode.position < startPosition + tableSize) {
            final byteIndex = byteCode.readInt32();
            final line = byteCode.readInt32();
            final linePos = byteCode.readInt32();

            table.set(byteIndex, {line:line, linePos: linePos});
        }

        return this;
    }
}