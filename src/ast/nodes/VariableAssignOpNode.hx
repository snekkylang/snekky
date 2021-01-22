package ast.nodes;

import lexer.Position;

class VariableAssignOpNode extends Node {

    public final name:IdentNode;
    public final value:OperatorNode;

    public function new(position:Position, name:IdentNode, value:OperatorNode) {
        super(position, NodeType.VariableAssignOp);
        
        this.name = name;
        this.value = value;
    }
}