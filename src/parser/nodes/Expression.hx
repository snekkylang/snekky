package parser.nodes;

class Expression extends Node {

    public final value:Node;

    public function new(line:Int, value:Node) {        
        this.value = value;
        this.type = NodeType.Expression;
    }
}