package compiler.debug;

class LocalVariableTable {

    final table:Map<Int, String> = new Map();

    public function new() {}

    public function define(byteIndex:Int, name:String) {
        table.set(byteIndex, name);
    }

    public function resolve(byteIndex:Int) {
        return table.get(byteIndex);
    }
} 