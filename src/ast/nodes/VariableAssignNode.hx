package ast.nodes;

class VariableAssignNode extends Node {

    public final name:Array<String>;
    public final value:ExpressionNode;
    public final destructure:Bool;

    public function new(position:Int, name:Array<String>, value:ExpressionNode, destructure:Bool) {
        super(position, NodeType.VariableAssign);
        
        this.name = name;
        this.value = value;
        this.destructure = destructure;
    }
}