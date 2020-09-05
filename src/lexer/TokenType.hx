package lexer;

enum abstract TokenType(Int) {
    final Illegal;
    final Eof;

    final Ident;
    final Number;
    final String;
    final Assign;
    final Plus;
    final Minus;
    final Multiply;
    final Divide;
    final Modulo;
    final Pow;
    final Bang;
    final Equal;
    final NotEqual;
    final LogicAnd;
    final LogicOr;
    final GreaterThan;
    final SmallerThan;
    final GreaterThanOrEqual;
    final SmallerThanOrEqual;
    final BitAnd;
    final BitOr;

    final Comma;
    final Semicolon;
    final Dot;
    final Colon;
    final LParen;
    final RParen;
    final LBrace;
    final RBrace;
    final LBracket;
    final RBracket;
    
    // Keywords
    final Function;
    final Let;
    final Mut;
    final True;
    final False;
    final If;
    final Else;
    final While;
    final Return;
    final Import;
    final Break;
}
