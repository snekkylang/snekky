package ast.nodes;

class WhileNode extends Node {

    public final condition:ExpressionNode;
    public final block:BlockNode;

    public function new(position:Int, condition:ExpressionNode, block:BlockNode) {
        super(position, NodeType.While);

        this.condition = condition;
        this.block = block;
    }
}