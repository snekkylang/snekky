package ast.nodes;

import lexer.Position;

class ContinueNode extends Node {

    public function new(position:Position) {
        super(position, NodeType.Continue);
    }
}