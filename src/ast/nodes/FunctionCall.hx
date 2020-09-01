package ast.nodes;

class FunctionCall extends Node {

    public final parameters:Array<Expression>;
    public final target:Expression;

    public function new(position:Int, target:Expression, parameters:Array<Expression>) {
        super(position, NodeType.FunctionCall);

        this.target = target;
        this.parameters = parameters;
    }
}