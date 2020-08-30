package parser.nodes.operators;

class Negation extends Operator {

    public function new(position:Int, right:Node) {
        super(position, NodeType.Negation, null, right);
    }
}