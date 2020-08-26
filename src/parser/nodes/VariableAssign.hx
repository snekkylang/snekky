package parser.nodes;

class VariableAssign extends Node {

    public final name:String;
    public final value:Expression;

    public function new(line:Int, name:String, value:Expression) {
        super(line, NodeType.VariableAssign);
        
        this.name = name;
        this.value = value;
    }
}