package parser.nodes.operators;

class Minus extends Operator {

    public function new(line:Int, left:Node, right:Node) {
        super(line, left, right);

        this.type = NodeType.Minus;
    }
}
