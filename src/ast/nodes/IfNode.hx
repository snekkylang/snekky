package ast.nodes;

import lexer.Position;

class IfNode extends Node {

    public final condition:ExpressionNode;
    public final consequence:BlockNode;
    public final alternative:Node;

    public function new(position:Position, condition:ExpressionNode, consequence:BlockNode, alternative:Node) {
        super(position, NodeType.If);

        this.condition = condition;
        this.consequence = consequence;
        this.alternative = alternative;
    }
}