package ast.nodes;

class VariableAssignNode extends Node {

    public final name:String;
    public final value:ExpressionNode;

    public function new(position:Int, name:String, value:ExpressionNode) {
        super(position, NodeType.VariableAssign);
        
        this.name = name;
        this.value = value;
    }
}