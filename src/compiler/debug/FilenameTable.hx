package compiler.debug;

import haxe.io.BytesInput;
import haxe.io.Bytes;
import haxe.io.BytesOutput;

private typedef FilenameEntry = {start:Int, end:Int, filename:String};

class FilenameTable {

    final table:Array<FilenameEntry> = [];

    public function new() {}

    public function define(start:Int, end:Int, filename:String) {
        table.push({start: start, end: end, filename: filename});
    }

    public function resolve(byteIndex:Int):String {
        var prev:FilenameEntry = null;

        for (entry in table) {
            if (entry.start <= byteIndex && entry.end >= byteIndex) {
                if (prev == null) {
                    prev = entry;
                    continue;
                }

                if (entry.start >= prev.start && entry.end <= prev.end) {
                    prev = entry;
                }
            }
        }

        return prev.filename;
    }

    public function concat(other:FilenameTable) {
        table.concat(other.table);
    }

    public function toByteCode():Bytes {
        final tableBytes = new BytesOutput();

        for (entry in table) {
            tableBytes.writeInt32(entry.start);
            tableBytes.writeInt32(entry.end);
            tableBytes.writeInt32(Bytes.ofString(entry.filename).length);
            tableBytes.writeString(entry.filename);
        }

        final output = new BytesOutput();
        output.writeInt32(tableBytes.length);
        output.write(tableBytes.getBytes());

        return output.getBytes();
    }

    public function fromByteCode(byteCode:BytesInput):FilenameTable {
        final tableSize = byteCode.readInt32();
        final startPosition = byteCode.position;

        while (byteCode.position < startPosition + tableSize) {
            final start = byteCode.readInt32();
            final end = byteCode.readInt32();
            final filenameLength = byteCode.readInt32();
            final filename = byteCode.readString(filenameLength);

            table.push({start: start, end: end, filename: filename});
        }

        return this;
    }
}