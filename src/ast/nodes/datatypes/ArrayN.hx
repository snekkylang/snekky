package ast.nodes.datatypes;

class ArrayN extends Node {

    public final values:Array<Expression>;

    public function new(position:Int, values:Array<Expression>) {
        super(position, NodeType.Array);

        this.values = values;
    }
}