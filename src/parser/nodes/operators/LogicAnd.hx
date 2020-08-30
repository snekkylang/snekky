package parser.nodes.operators;

class LogicAnd extends Operator {

    public function new(position:Int, left:Node, right:Node) {
        super(position, NodeType.LogicAnd, left, right);
    }
}