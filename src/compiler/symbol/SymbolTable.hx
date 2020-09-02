package compiler.symbol;

import compiler.symbol.SymbolScope;

class SymbolTable {

    var symbolIndex = 0;
    public var currentScope:SymbolScope = new SymbolScope(null);

    public function new() {
        define("print", false, SymbolOrigin.BuiltIn);
    }

    public function newScope() {
        currentScope = new SymbolScope(currentScope);
    }

    public function setParent() {
        currentScope = currentScope.parent;
    }

    public function define(name:String, mutable:Bool, origin:SymbolOrigin):Symbol {
        final symbol = new Symbol(symbolIndex, mutable, origin);
        currentScope.define(name, symbol);
        symbolIndex++;
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