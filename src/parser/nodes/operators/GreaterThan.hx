package parser.nodes.operators;

class GreaterThan extends Operator {

    public function new(position:Int, left:Node, right:Node) {
        super(position, NodeType.GreaterThan, left, right);
    }
}