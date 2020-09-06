package ast.nodes;

class IfNode extends Node {

    public final condition:ExpressionNode;
    public final consequence:BlockNode;
    public final alternative:BlockNode;

    public function new(position:Int, condition:ExpressionNode, consequence:BlockNode, alternative:BlockNode) {
        super(position, NodeType.If);

        this.condition = condition;
        this.consequence = consequence;
        this.alternative = alternative;
    }
}