package ast.nodes.datatypes;

import lexer.Position;

class NullNode extends Node {

    public function new(position:Position) {
        super(position, NodeType.Null);
    }
}