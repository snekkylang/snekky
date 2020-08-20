package parser.nodes;

class Boolean extends Node {

    public final value:Bool;

    public function new(line:Int, value:Bool) {
        this.line = line;
        this.value = value;
        this.type = NodeType.Boolean;
    }
}