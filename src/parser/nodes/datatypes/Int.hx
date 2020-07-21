package parser.nodes.datatypes;

class IntN extends Node {

    public final value:Int;

    public function new(line:Int, value:Int) {
        this.line = line;
        this.type = NodeType.Int;
        this.value = value;
    }
}
