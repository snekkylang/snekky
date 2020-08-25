package compiler.symbol;

class SymbolTable {

    final symbols:Map<String, Symbol> = new Map();
    var symbolIndex = 0;

    public function new() { }

    public function define(name):Symbol {
        final symbol = new Symbol(name, symbolIndex);
        symbolIndex++;
        symbols.set(name, symbol);
        return symbol;
    }

    public function resolve(name):Symbol {
        return symbols.get(name);
    }
}