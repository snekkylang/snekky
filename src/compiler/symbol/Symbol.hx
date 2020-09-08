package compiler.symbol;

class Symbol {

    public final index:Int;
    public final mutable:Bool;

    public function new(index:Int, mutable:Bool) {
        this.index = index;
        this.mutable = mutable;
    }
}