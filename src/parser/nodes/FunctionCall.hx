package parser.nodes;

class FunctionCall extends Node {

    public final parameters:Array<Expression>;
    public final target:Expression;

    public function new(line:Int, target:Expression, parameters:Array<Expression>) {
        super(line, NodeType.FunctionCall);

        this.target = target;
        this.parameters = parameters;
    }
}