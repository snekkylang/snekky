package compiler.symbol;

class Symbol {

    public final index:Int;
    public final mutable:Bool;
    public final origin:SymbolOrigin;

    public function new(index:Int, mutable:Bool, origin:SymbolOrigin) {
        this.index = index;
        this.mutable = mutable;
        this.origin = origin;
    }
}