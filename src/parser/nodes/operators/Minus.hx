package parser.nodes.operators;

class Minus extends Operator {

    public function new(position:Int, left:Node, right:Node) {
        super(position, NodeType.Minus, left, right);
    }
}
