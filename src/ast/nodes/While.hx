package ast.nodes;

class While extends Node {

    public final condition:Expression;
    public final block:Block;

    public function new(position:Int, condition:Expression, block:Block) {
        super(position, NodeType.While);

        this.condition = condition;
        this.block = block;
    }
}