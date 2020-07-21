package parser.nodes;

class Block extends Node {

    var body:Array<Node> = [];

    public function new(line:Int) {
        this.type = NodeType.Block;
    }

    public function addNode(node:Node) {
        body.push(node);
    }
}