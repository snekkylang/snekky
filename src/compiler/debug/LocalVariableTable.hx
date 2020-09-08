package compiler.debug;

import haxe.io.BytesInput;
import haxe.io.Bytes;
import haxe.io.BytesOutput;

class LocalVariableTable {

    final table:Map<Int, String> = new Map();

    public function new() {}

    public function define(byteIndex:Int, name:String) {
        table.set(byteIndex, name);
    }

    public function resolve(byteIndex:Int) {
        return table.get(byteIndex);
    }

    public function toByteCode():Bytes {
        final output = new BytesOutput();

        output.writeInt32(Lambda.count(table));

        for (byteIndex => localName in table) {
            output.writeInt32(byteIndex);
            output.writeInt32(Bytes.ofString(localName).length);
            output.writeString(localName);
        }

        return output.getBytes();
    }

    public function fromByteCode(byteCode:BytesInput):LocalVariableTable {
        final tableSize = byteCode.readInt32();

        for (_ in 0...tableSize) {
            final byteIndex = byteCode.readInt32();
            final localNameLength = byteCode.readInt32();
            final localName = byteCode.readString(localNameLength);

            table.set(byteIndex, localName);
        }

        return this;
    }
} 