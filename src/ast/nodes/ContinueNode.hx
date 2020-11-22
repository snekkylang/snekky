package ast.nodes;

class ContinueNode extends Node {

    public function new(position:Int) {
        super(position, NodeType.Continue);
    }
}