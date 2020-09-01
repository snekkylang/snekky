package ast.nodes;

class Boolean extends Node {

    public final value:Bool;

    public function new(position:Int, value:Bool) {
        super(position, NodeType.Boolean);

        this.value = value;
    }
}