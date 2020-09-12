package ast.nodes.datatypes;

class NullNode extends Node {

    public function new(position:Int) {
        super(position, NodeType.Null);
    }
}