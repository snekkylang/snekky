package ast.nodes;

import lexer.Position;

class Node {

    public final position:Position;
    public var type(default, null):NodeType;

    public function new(position:Position, type:NodeType) {
        this.position = position;
        this.type = type;
    }
}