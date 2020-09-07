package ast.nodes;

class IndexAssign extends Node {

    public final index:ExpressionNode;
    public final value:ExpressionNode;

    public function new(position, index:ExpressionNode, value:ExpressionNode) {
        super(position, NodeType.IndexAssign);

        this.index = index;
        this.value = value;
    }
}