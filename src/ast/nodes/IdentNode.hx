package ast.nodes;

import lexer.Position;

class IdentNode extends Node {

    public final value:String;

    public function new(position:Position, value:String) {
        super(position, NodeType.Ident);

        this.value = value;
    }
}