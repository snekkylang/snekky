package parser.nodes.operators;

class Negation extends Operator {

    public function new(line:Int, right:Node) {
        super(line, null, right);

        this.type = NodeType.Negation;
    }
}