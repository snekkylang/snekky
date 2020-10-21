package ast.nodes;

class ForNode extends Node {

    public final variable:VariableNode;
    public final iterator:ExpressionNode;
    public final block:BlockNode;

    public function new(position:Int, variable:VariableNode, iterator:ExpressionNode, block:BlockNode) {
        super(position, NodeType.For);

        this.variable = variable;
        this.iterator = iterator;
        this.block = block;
    }
}