package parser.nodes.operators;

class Modulo extends Operator {

    public function new(position:Int, left:Node, right:Node) {
        super(position, NodeType.Modulo, left, right);
    }
}
