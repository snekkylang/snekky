package parser.nodes.operators;

class GreaterThan extends Operator {

    public function new(line:Int, left:Node, right:Node) {
        super(line, NodeType.GreaterThan, left, right);
    }
}