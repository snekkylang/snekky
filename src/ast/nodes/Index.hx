package ast.nodes;

class Index extends Node {

    public final target:Expression;
    public final index:Expression;

    public function new(position:Int, target:Expression, index:Expression) {
        super(position, NodeType.Index);

        this.target = target;
        this.index = index;
    }
}