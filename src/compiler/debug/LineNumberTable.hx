package compiler.debug;

class LineNumberTable {

    final table:Map<Int, {line:Int, linePos:Int}> = new Map();

    public function new() {}

    public function define(byteIndex:Int, sourcePosition:{line:Int, linePos:Int}) {
        table.set(byteIndex, sourcePosition);
    }

    public function resolve(byteIndex:Int) {
        return table.get(byteIndex);
    }
}