package compiler.symbol;

class SymbolTable {

    final scopes:Array<SymbolScope> = [];
    var symbolIndex = 0;
    var currentScope:SymbolScope = null;

    public function new() { }

    public function newScope() {
        currentScope = new SymbolScope(currentScope);
    }

    public function setParent() {
        currentScope = currentScope.parent;
    }

    public function define(name:String, mutable:Bool):Symbol {
        symbolIndex++;
        final symbol = new Symbol(symbolIndex, mutable);
        currentScope.define(name, symbol);
        return symbol;
    }

    public function resolve(name:String):Symbol {
        var cScope = currentScope;

        while (cScope != null && !cScope.exists(name)) {
            cScope = cScope.parent;
        }

        if (cScope == null) {
            return null;
        }

        return cScope.resolve(name);
    }
}