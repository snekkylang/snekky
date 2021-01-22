package ast.nodes.datatypes;

import lexer.Position;

class BooleanNode extends Node {

    public final value:Bool;

    public function new(position:Position, value:Bool) {
        super(position, NodeType.Boolean);

        this.value = value;
    }
}