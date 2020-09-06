package ast.nodes;

class ReturnNode extends Node {

    public final value:ExpressionNode;

    public function new(position:Int, value:ExpressionNode) {
        super(position, NodeType.Return);

        this.value = value;
    }
}