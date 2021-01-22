package ast.nodes;

import lexer.Position;

class StatementNode extends Node {

    public final value:ExpressionNode;

    public function new(position:Position, value:ExpressionNode) {
        super(position, NodeType.Statement);

        this.value = value;
    }
}