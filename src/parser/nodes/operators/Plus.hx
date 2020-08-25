package parser.nodes.operators;

class Plus extends Operator {

    public function new(line:Int, left:Node, right:Node) {
        super(line, NodeType.Plus, left, right);
    }
}
