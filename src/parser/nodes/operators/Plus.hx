package parser.nodes.operators;

class Plus extends Operator {

    public function new(position:Int, left:Node, right:Node) {
        super(position, NodeType.Plus, left, right);
    }
}
