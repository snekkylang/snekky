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
    LogicOr;
    LogicAnd;
    SmallerThan;
    GreaterThan;
    Equal;
    Negation;

    Int;
    String;
    Function;
    Boolean;

    Return;
    If;
    While;
}