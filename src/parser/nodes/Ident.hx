package parser.nodes;

class Ident extends Node {

    public final value:String;

    public function new(line:Int, value:String) {
        this.line = line;
        this.value = value;
        this.type = NodeType.Ident;
    }
}