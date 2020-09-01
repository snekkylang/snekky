package ast.nodes;

class Break extends Node {

    public function new(position:Int) {
        super(position, NodeType.Break);
    }
}