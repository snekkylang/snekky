package ast.nodes.datatypes;

import lexer.Position;

class StringNode extends Node {

    public final value:String;

    public function new(position:Position, value:String) {
        super(position, NodeType.String);

        this.value = value;
    }
}
