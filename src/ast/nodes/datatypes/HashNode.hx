package ast.nodes.datatypes;

import lexer.Position;

class HashNode extends Node {

    public final values:Map<ExpressionNode, ExpressionNode>;

    public function new(position:Position, values:Map<ExpressionNode, ExpressionNode>) {
        super(position, NodeType.Hash);

        this.values = values;
    }
}