package compiler.symbol;

enum abstract SymbolOrigin(Int) {
    final BuiltIn;
    final UserDefined;
}