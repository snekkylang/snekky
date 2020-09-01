package ast.nodes.datatypes;

class FloatN extends Node {

    public final value:Float;

    public function new(position:Int, value:Float) {
        super(position, NodeType.Float);

        this.value = value;
    }
}
