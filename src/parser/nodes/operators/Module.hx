package parser.nodes.operators;

class Modulo extends Operator {

    public function new(line:Int, left:Node, right:Node) {
        super(line, NodeType.Modulo, left, right);
    }
}
