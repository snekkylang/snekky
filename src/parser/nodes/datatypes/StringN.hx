package parser.nodes.datatypes;

class StringN extends Node {

    public final value:String;

    public function new(line:Int, value:String) {
        this.type = NodeType.String;
        this.value = value;
    }
}
