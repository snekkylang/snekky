package ast.nodes;

class IndexAssignNode extends Node {

    public final index:Node;
    public final value:ExpressionNode;

    public function new(position, index:Node, value:ExpressionNode) {
        super(position, NodeType.IndexAssign);

        this.index = index;
        this.value = value;
    }
}