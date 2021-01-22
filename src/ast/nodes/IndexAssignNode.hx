package ast.nodes;

import lexer.Position;

class IndexAssignNode extends Node {

    public final index:Node;
    public final value:ExpressionNode;

    public function new(position:Position, index:Node, value:ExpressionNode) {
        super(position, NodeType.IndexAssign);

        this.index = index;
        this.value = value;
    }
}