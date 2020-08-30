package parser.nodes.datatypes;

class IntN extends Node {

    public final value:Int;

    public function new(line:Int, value:Int) {
        super(line, NodeType.Int);

        this.value = value;
    }
}
