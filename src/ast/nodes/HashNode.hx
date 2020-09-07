package ast.nodes;

class HashNode extends Node {

    public final values:Map<ExpressionNode, ExpressionNode>;

    public function new(position:Int, values:Map<ExpressionNode, ExpressionNode>) {
        super(position, NodeType.Hash);

        this.values = values;
    }
}