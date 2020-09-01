package ast.nodes;

class Block extends Node {

    public final body:Array<Node> = [];

    public function new(position:Int) {
        super(position, NodeType.Block);
    }

    public function addNode(node:Node) {
        body.push(node);
    }
}