package parser.nodes.operators;

class Divide extends Operator {
    
    public function new(position:Int, left:Node, right:Node) {
        super(position, NodeType.Divide, left, right);
    }
}
