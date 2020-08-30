package parser.nodes.operators;

class Equal extends Operator {

    public function new(position:Int, left:Node, right:Node) {
        super(position, NodeType.Equal, left, right);
    }
}