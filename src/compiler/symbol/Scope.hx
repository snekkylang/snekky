package compiler.symbol;

class Scope {

    public final parent:Scope = null;
    final symbols:Map<String, Symbol> = new Map();

    public function new(parent:Scope) {
        this.parent = parent;
    }

    public function resolve(name:String):Symbol {
        return symbols.get(name);
    }

    public function define(name:String, value:Symbol) {
        symbols.set(name, value);
    }

    public function exists(name):Bool {
        return resolve(name) != null;
    }
}