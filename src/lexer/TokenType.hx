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
    Asterisk;
    Slash;
    Percent;
    Pow;
    Bang;
    Equals;
    NotEquals;
    LogicAnd;
    LogicOr;
    GreaterThan;
    LessThan;
    GreaterThanOrEqual;
    LessThanOrEqual;
    BitAnd;
    BitOr;
    ConcatString;

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
    Null;
}
