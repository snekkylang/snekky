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
    StringConc;
    Equal;
    Negation;
    Inversion;
    Assign;

    Float;
    String;
    Function;
    Boolean;
    Array;
    Hash;

    Return;
    Break;
    If;
    While;

    Index;
}