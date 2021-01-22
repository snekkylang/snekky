package ast.nodes;

import lexer.Position;

class BreakNode extends Node {

    public function new(position:Position) {
        super(position, NodeType.Break);
    }
}