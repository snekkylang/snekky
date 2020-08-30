package parser.nodes.datatypes;

class IntN extends Node {

    public final value:Int;

    public function new(position:Int, value:Int) {
        super(position, NodeType.Int);

        this.value = value;
    }
}
