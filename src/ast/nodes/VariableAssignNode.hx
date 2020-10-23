package ast.nodes;

class VariableAssignNode extends Node {

    public final name:IdentNode;
    public final value:ExpressionNode;

    public function new(position:Int, name:IdentNode, value:ExpressionNode) {
        super(position, NodeType.VariableAssign);
        
        this.name = name;
        this.value = value;
    }
}