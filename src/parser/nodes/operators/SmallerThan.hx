package parser.nodes.operators;

class SmallerThan extends Operator {

    public function new(position:Int, left:Node, right:Node) {
        super(position, NodeType.SmallerThan, left, right);
    }
}