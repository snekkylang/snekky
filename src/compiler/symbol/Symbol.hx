package compiler.symbol;

class Symbol {

    public final position:Int;
    public final name:String;
    public final index:Int;
    public final mutable:Bool;

    public function new(position:Int, name:String, index:Int, mutable:Bool) {
        this.position = position;
        this.name = name;
        this.index = index;
        this.mutable = mutable;
    }
}