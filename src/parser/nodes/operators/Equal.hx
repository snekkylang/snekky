package parser.nodes.operators;

class Equal extends Operator {

    public function new(line:Int, left:Node, right:Node) {
        super(line, NodeType.Equal, left, right);
    }
}