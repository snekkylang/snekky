package ast;

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
    Inversion;

    Float;
    String;
    Function;
    Boolean;

    Return;
    Break;
    If;
    While;
}