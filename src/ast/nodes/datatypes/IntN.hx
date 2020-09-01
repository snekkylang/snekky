package ast.nodes.datatypes;

import haxe.Int64;

class IntN extends Node {

    public final value:Int64;

    public function new(position:Int, value:Int64) {
        super(position, NodeType.Int);

        this.value = value;
    }
}
