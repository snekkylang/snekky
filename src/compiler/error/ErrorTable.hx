package compiler.error;

import haxe.io.BytesInput;
import haxe.io.Bytes;
import haxe.io.BytesOutput;

private typedef ErrorEntry = {start:Int, end:Int, target:Int};

class ErrorTable {

    final table:Array<ErrorEntry> = [];

    public function new() {}

    public function define(start:Int, end:Int, target:Int) {
        table.push({start: start, end: end, target: target});
    }

    public function resolve(byteIndex:Int):Int {
        var prev:ErrorEntry = null;

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

        return prev == null ? -1 : prev.target;
    }
    
    public function toByteCode():Bytes {
        final tableBytes = new BytesOutput();

        for (entry in table) {
            tableBytes.writeInt32(entry.start);
            tableBytes.writeInt32(entry.end);
            tableBytes.writeInt32(entry.target);
        }

        final output = new BytesOutput();
        output.writeInt32(tableBytes.length);
        output.write(tableBytes.getBytes());

        return output.getBytes();
    }

    public function fromByteCode(byteCode:BytesInput):ErrorTable {
        final tableSize = byteCode.readInt32();
        final startPosition = byteCode.position;

        while (byteCode.position < startPosition + tableSize) {
            final start = byteCode.readInt32();
            final end = byteCode.readInt32();
            final target = byteCode.readInt32();

            table.push({start: start, end: end, target: target});
        }

        return this;
    }
}