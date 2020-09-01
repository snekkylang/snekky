package ast.nodes.datatypes;

class StringN extends Node {

    public final value:String;

    public function new(position:Int, value:String) {
        super(position, NodeType.String);

        this.value = value;
    }
}
