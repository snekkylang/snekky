package ast.nodes;

class Statement extends Node {

    public final value:Expression;

    public function new(position:Int, value:Expression) {
        super(position, NodeType.Statement);

        this.value = value;
    }
}