package ast.nodes;

class IndexAssign extends Node {

    public final index:Expression;
    public final value:Expression;

    public function new(position:Int, index:Expression, value:Expression) {
        super(position, NodeType.IndexAssign);

        this.index = index;
        this.value = value;
    }
}