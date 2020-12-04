package ast.nodes.datatypes;

class ArrayNode extends Node {

    public final values:Array<ExpressionNode>;

    public function new(position:Int, values:Array<ExpressionNode>) {
        super(position, NodeType.Array);

        this.values = values;
    }
}