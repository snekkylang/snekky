package compiler.debug;

import haxe.io.BytesInput;
import haxe.io.Bytes;
import haxe.io.BytesOutput;

class FilenameTable {

    final table:Map<Int, {end:Int, filename:String}> = new Map();

    public function new() {}

    public function define(start:Int, end:Int, filename:String) {
        if (!table.exists(start)) {
            table.set(start, {end: end, filename: filename});
        }
    }

    public function resolve(byteIndex:Int):String {
        final entry = table.get(byteIndex);

        if (entry != null) {
            return if (entry.end >= byteIndex) {
                entry.filename;
            } else {
                resolve(byteIndex - 1);
            }
        }

        return resolve(byteIndex - 1);
    }

    public function toByteCode():Bytes {
        final tableBytes = new BytesOutput();

        for (start => entry in table) {
            tableBytes.writeInt32(start);
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

            table.set(start, {end: end, filename: filename});
        }

        return this;
    }
}