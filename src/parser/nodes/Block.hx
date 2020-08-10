package parser.nodes;

class Block extends Node {

    public final body:Array<Node> = [];

    public function new(line:Int) {
        this.type = NodeType.Block;
    }

    public function addNode(node:Node) {
        body.push(node);
    }
}