package ast;

enum NodeType {
    File;
    Block;
    Expression;
    Statement;
    Variable;
    VariableAssign;
    VariableAssignOp;
    DestructureArray;
    DestructureHash;
    Ident;
    FunctionCall;

    Add;
    Subtract;
    Multiply;
    Divide;
    Modulo;
    LogicOr;
    LogicAnd;
    LessThan;
    LessThanOrEqual;
    GreaterThan;
    GreaterThanOrEqual;
    ConcatString;
    Equals;
    NotEquals;
    Negate;
    Not;

    Float;
    String;
    Function;
    Boolean;
    Array;
    Hash;
    Null;

    Return;
    Break;
    If;
    While;
    For;

    Index;
    IndexAssign;
}