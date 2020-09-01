package ast.nodes;

class Variable extends Node {

    public final name:String;
    public final value:Expression;
    public final mutable:Bool;

    public function new(position:Int, name:String, value:Expression, mutable:Bool) {
        super(position, NodeType.Variable);
        
        this.name = name;
        this.value = value;
        this.mutable = mutable;
    }
}