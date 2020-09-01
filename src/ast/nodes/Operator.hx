package ast.nodes;

class Operator extends Node {
    
    public var left:Node;
    public var right:Node;

    public function new(position:Int, type:NodeType, left:Node, right:Node) {
        super(position, type);

        this.left = left;
        this.right = right;
    }
}