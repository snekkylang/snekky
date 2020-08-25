package parser.nodes.operators;

class Negation extends Operator {

    public function new(line:Int, right:Node) {
        super(line, NodeType.Negation, null, right);
    }
}