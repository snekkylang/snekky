package ast.nodes;

class VariableAssign extends Node {

    public final name:String;
    public final value:Expression;

    public function new(position:Int, name:String, value:Expression) {
        super(position, NodeType.VariableAssign);
        
        this.name = name;
        this.value = value;
    }
}