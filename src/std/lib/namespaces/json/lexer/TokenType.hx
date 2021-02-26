package std.lib.namespaces.json.lexer;

enum TokenType {
    Illegal;
    Eof;

    Number;
    String;
    Null;
    True;
    False;

    Minus;
    
    Comma;
    Colon;
    LBrace;
    RBrace;
    LBracket;
    RBracket;
}
