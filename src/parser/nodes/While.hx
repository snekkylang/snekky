package parser.nodes;

class While extends Node {

    public final condition:Expression;
    public final block:Block;

    public function new(line:Int, condition:Expression, block:Block) {
        super(line, NodeType.While);

        this.condition = condition;
        this.block = block;
    }
}