package ast.nodes;

class CallNode extends Node {

    public final parameters:Array<ExpressionNode>;
    public final target:ExpressionNode;

    public function new(position:Int, target:ExpressionNode, parameters:Array<ExpressionNode>) {
        super(position, NodeType.FunctionCall);

        this.target = target;
        this.parameters = parameters;
    }
}