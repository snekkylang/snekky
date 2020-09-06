package ast.nodes;

class BreakNode extends Node {

    public function new(position:Int) {
        super(position, NodeType.Break);
    }
}