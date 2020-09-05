package ast;

enum abstract NodeType(Int) {
    final Block;
    final Expression;
    final Statement;
    final Variable;
    final VariableAssign;
    final Ident;
    final FunctionCall;

    final Plus;
    final Minus;
    final Multiply;
    final Divide;
    final Modulo;
    final LogicOr;
    final LogicAnd;
    final SmallerThan;
    final GreaterThan;
    final StringConc;
    final Equal;
    final Negation;
    final Inversion;

    final Float;
    final String;
    final Function;
    final Boolean;

    final Return;
    final Break;
    final If;
    final While;
}