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

    public function define(name:String):Int {
        symbolIndex++;
        currentScope.define(name, symbolIndex);
        return symbolIndex;
    }

    public function resolve(name:String):Int {
        var cScope = currentScope;

        while (cScope != null && !cScope.exists(name)) {
            cScope = cScope.parent;
        }

        return cScope.resolve(name);
    }
}