package parser.nodes;

class Expression extends Node {

    public final value:Node;

    public function new(line:Int, value:Node) {    
        super(line, NodeType.Expression);
        
        this.value = value;
    }
}