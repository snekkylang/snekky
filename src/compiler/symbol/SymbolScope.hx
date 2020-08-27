package compiler.symbol;

class SymbolScope {

    public final parent:SymbolScope = null;
    final symbols:Map<String, Int> = new Map();

    public function new(parent:SymbolScope) {
        this.parent = parent;
    }

    public function resolve(name:String):Null<Int> {
        return symbols.get(name);
    }

    public function define(name:String, value:Int) {
        symbols.set(name, value);
    }

    public function exists(name):Bool {
        return resolve(name) != null;
    }
}