package ast.nodes.datatypes;

class StringNode extends Node {

    public final value:String;

    public function new(position:Int, value:String) {
        super(position, NodeType.String);

        this.value = value;
    }
}
