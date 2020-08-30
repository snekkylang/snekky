package parser.nodes.operators;

class LogicOr extends Operator {

    public function new(position:Int, left:Node, right:Node) {
        super(position, NodeType.LogicOr, left, right);
    }
}