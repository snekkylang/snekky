package ast.nodes.datatypes;

import lexer.Position;

class FloatNode extends Node {

    public final value:Float;

    public function new(position:Position, value:Float) {
        super(position, NodeType.Float);

        this.value = value;
    }
}
