package ast.nodes;

import lexer.Position;

class ExpressionNode extends Node {

    public final value:Node;

    public function new(position:Position, value:Node) {    
        super(position, NodeType.Expression);
        
        this.value = value;
    }
}