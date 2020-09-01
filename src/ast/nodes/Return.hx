package ast.nodes;

class Return extends Node {

    public final value:Expression;

    public function new(position:Int, value:Expression) {
        super(position, NodeType.Return);

        this.value = value;
    }
}