package ast.nodes;

import lexer.Position;

class BlockNode extends Node {

    public final body:Array<Node> = [];

    public function new(position:Position) {
        super(position, NodeType.Block);
    }

    public function addNode(node:Node) {
        body.push(node);
    }
}