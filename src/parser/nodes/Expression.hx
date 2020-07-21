package parser.nodes;

class Expression extends Node {

    public final value:Array<Node>;

    public function new(line:Int, value:Array<Node>) {        
        this.value = value;
        this.type = NodeType.Expression;
    }
}