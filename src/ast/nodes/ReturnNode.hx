package ast.nodes;

import lexer.Position;

class ReturnNode extends Node {

    public final value:ExpressionNode;

    public function new(position:Position, value:ExpressionNode) {
        super(position, NodeType.Return);

        this.value = value;
    }
}