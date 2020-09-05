package lexer;

enum TokenType {
    Illegal;
    Eof;

    Ident;
    Number;
    String;
    Assign;
    Plus;
    Minus;
    Multiply;
    Divide;
    Modulo;
    Pow;
    Bang;
    Equal;
    NotEqual;
    LogicAnd;
    LogicOr;
    GreaterThan;
    SmallerThan;
    GreaterThanOrEqual;
    SmallerThanOrEqual;
    BitAnd;
    BitOr;

    Comma;
    Semicolon;
    Dot;
    Colon;
    LParen;
    RParen;
    LBrace;
    RBrace;
    LBracket;
    RBracket;
    
    // Keywords
    Function;
    Let;
    Mut;
    True;
    False;
    If;
    Else;
    While;
    Return;
    Import;
    Break;
}
