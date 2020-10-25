package ast.nodes;

class VariableAssignOpNode extends Node {

    public final name:IdentNode;
    public final value:OperatorNode;

    public function new(position:Int, name:IdentNode, value:OperatorNode) {
        super(position, NodeType.VariableAssignOp);
        
        this.name = name;
        this.value = value;
    }
}