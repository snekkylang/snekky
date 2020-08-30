package parser.nodes.operators;

class Multiply extends Operator {

    public function new(position:Int, left:Node, right:Node) {
        super(position, NodeType.Multiply, left, right);
    }
}
