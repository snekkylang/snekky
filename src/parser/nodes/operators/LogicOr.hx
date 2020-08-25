package parser.nodes.operators;

class LogicOr extends Operator {

    public function new(line:Int, left:Node, right:Node) {
        super(line, NodeType.LogicOr, left, right);
    }
}