package ast.nodes;

import lexer.Position;

class DestructureHashNode extends Node {

    public final names:Array<String>;

    public function new(position:Position, names:Array<String>) {
        super(position, NodeType.DestructureHash);
        
        this.names = names;
    }
}