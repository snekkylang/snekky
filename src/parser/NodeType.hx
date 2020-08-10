package parser;

enum NodeType {
    Block;
    Expression;
    Node;
    Variable;
    Ident;
    FunctionCall;

    Plus;
    Minus;
    Multiply;
    Divide;
    LParen;
    RParen;

    Int;
    String;
}