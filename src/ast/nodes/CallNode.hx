package ast.nodes;

import lexer.Position;

class CallNode extends Node {

    public final parameters:Array<ExpressionNode>;
    public final target:ExpressionNode;

    public function new(position:Position, target:ExpressionNode, parameters:Array<ExpressionNode>) {
        super(position, NodeType.FunctionCall);

        this.target = target;
        this.parameters = parameters;
    }
}