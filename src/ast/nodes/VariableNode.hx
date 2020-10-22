package ast.nodes;

class VariableNode extends Node {

    public final name:Node;
    public final value:ExpressionNode;
    public final mutable:Bool;

    public function new(position:Int, name:Node, value:ExpressionNode, mutable:Bool) {
        super(position, NodeType.Variable);
        
        this.name = name;
        this.value = value;
        this.mutable = mutable;
    }
}