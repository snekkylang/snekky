package lexer;

enum TokenType {
    Illegal;
    Eof;

    Ident;
    NumberDec;
    NumberHex;
    String;
    Assign;
    PlusAssign;
    MinusAssign;
    AsteriskAssign;
    SlashAssign;
    PercentAssign;
    BitAndAssign;
    BitOrAssign;
    BitShiftLeftAssign;
    BitShiftRightAssign;
    BitXorAssign;
    Plus;
    Minus;
    Asterisk;
    Slash;
    Percent;
    Pow;
    Bang;
    Equals;
    NotEquals;
    And;
    Or;
    GreaterThan;
    LessThan;
    GreaterThanOrEqual;
    LessThanOrEqual;
    BitAnd;
    BitOr;
    BitShiftLeft;
    BitShiftRight;
    BitXor;
    BitNot;
    ConcatString;
    Regex;

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
    Arrow;
    
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
    Continue;
    Null;
    For;
    In;
    When;
}
