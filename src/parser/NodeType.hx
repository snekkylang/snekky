package parser;

enum NodeType {
    Block;
    Expression;
    Statement;
    Variable;
    VariableAssign;
    Ident;
    FunctionCall;

    Plus;
    Minus;
    Multiply;
    Divide;
    Modulo;
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