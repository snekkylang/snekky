package ast.nodes.datatypes;

import lexer.Position;

class ArrayNode extends Node {

    public final values:Array<ExpressionNode>;

    public function new(position:Position, values:Array<ExpressionNode>) {
        super(position, NodeType.Array);

        this.values = values;
    }
}