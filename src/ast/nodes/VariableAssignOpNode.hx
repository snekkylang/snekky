package ast.nodes;

class VariableAssignOpNode extends Node {

    public final name:IdentNode;
    public final op:OperatorNode;

    public function new(position:Int, name:IdentNode, op:OperatorNode) {
        super(position, NodeType.VariableAssignOp);
        
        this.name = name;
        this.op = op;
    }
}