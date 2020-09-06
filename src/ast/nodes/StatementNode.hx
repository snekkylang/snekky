package ast.nodes;

class StatementNode extends Node {

    public final value:ExpressionNode;

    public function new(position:Int, value:ExpressionNode) {
        super(position, NodeType.Statement);

        this.value = value;
    }
}