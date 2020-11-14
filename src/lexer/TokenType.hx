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
    BitAndAssign;
    BitOrAssign;
    BitShiftLeftAssign;
    BitShiftRightAssign;
    BitXorAssign;
    BitNotAssign;
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
    Null;
    For;
    In;
    When;
}
