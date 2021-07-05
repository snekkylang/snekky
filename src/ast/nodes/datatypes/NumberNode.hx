package ast.nodes.datatypes;

import lexer.Position;

class NumberNode extends Node {

    public final value:Float;

    public function new(position:Position, value:Float) {
        super(position, NodeType.Float);

        this.value = value;
    }
}
