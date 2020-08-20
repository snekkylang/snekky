package parser.nodes.operators;

class Operator extends Node {
    
    public var left:Node;
    public var right:Node;

    public function new(line:Int, left:Node, right:Node) {
        this.line = line;
        this.left = left;
        this.right = right;
    }
}
