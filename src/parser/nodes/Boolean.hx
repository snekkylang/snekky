package parser.nodes;

class Boolean extends Node {

    public final value:Bool;

    public function new(line:Int, value:Bool) {
        super(line, NodeType.Boolean);

        this.value = value;
    }
}