package ast.nodes;

import lexer.Position;

class DestructureArrayNode extends Node {

    public final names:Array<String>;

    public function new(position:Position, names:Array<String>) {
        super(position, NodeType.DestructureArray);
        
        this.names = names;
    }
}