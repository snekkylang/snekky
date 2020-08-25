package parser.nodes;

class Block extends Node {

    public final body:Array<Node> = [];

    public function new(line:Int) {
        super(line, NodeType.Block);
    }

    public function addNode(node:Node) {
        body.push(node);
    }
}