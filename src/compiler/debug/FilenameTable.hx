package compiler.debug;

import haxe.io.BytesInput;
import haxe.io.Bytes;
import haxe.io.BytesOutput;

private typedef FilenameEntry = {start:Int, end:Int, fileName:String};

class FileNameTable {

    final table:Array<FilenameEntry> = [];

    public function new() {}

    public function define(start:Int, end:Int, fileName:String) {
        table.push({start: start, end: end, fileName: fileName});
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

        return prev == null ? null : prev.fileName;
    }
    
    public function toByteCode():Bytes {
        final tableBytes = new BytesOutput();

        for (entry in table) {
            tableBytes.writeInt32(entry.start);
            tableBytes.writeInt32(entry.end);
            tableBytes.writeInt32(Bytes.ofString(entry.fileName).length);
            tableBytes.writeString(entry.fileName);
        }

        final output = new BytesOutput();
        output.writeInt32(tableBytes.length);
        output.write(tableBytes.getBytes());

        return output.getBytes();
    }

    public function fromByteCode(byteCode:BytesInput):FileNameTable {
        final tableSize = byteCode.readInt32();
        final startPosition = byteCode.position;

        while (byteCode.position < startPosition + tableSize) {
            final start = byteCode.readInt32();
            final end = byteCode.readInt32();
            final fileNameLength = byteCode.readInt32();
            final fileName = byteCode.readString(fileNameLength);

            table.push({start: start, end: end, fileName: fileName});
        }

        return this;
    }
}