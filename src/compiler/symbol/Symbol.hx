package compiler.symbol;

class Symbol {

    public final name:String;
    public final index:Int;

    public function new(name:String, index:Int) {
        this.name = name;
        this.index = index;
    }
}