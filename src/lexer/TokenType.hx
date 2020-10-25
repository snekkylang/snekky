package lexer;

enum TokenType {
    Illegal;
    Eof;

    Ident;
    Number;
    String;
    Assign;
    PlusAssign;
    MinusAssign;
    AsteriskAssign;
    SlashAssign;
    PercentAssign;
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
    ExclusiveRange;
    InclusiveRange;
    
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
    For;
    In;
}
