package ast.nodes;

import lexer.Position;

class IndexNode extends Node {

    public final target:ExpressionNode;
    public final index:ExpressionNode;

    public function new(position:Position, target:ExpressionNode, index:ExpressionNode) {
        super(position, NodeType.Index);

        this.target = target;
        this.index = index;
    }
}