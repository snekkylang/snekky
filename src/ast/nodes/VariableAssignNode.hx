package ast.nodes;

class VariableAssignNode extends Node {

    public final name:IdentNode;
    public final value:ExpressionNode;
    public final destructure:Bool;

    public function new(position:Int, name:IdentNode, value:ExpressionNode, destructure:Bool) {
        super(position, NodeType.VariableAssign);
        
        this.name = name;
        this.value = value;
        this.destructure = destructure;
    }
}