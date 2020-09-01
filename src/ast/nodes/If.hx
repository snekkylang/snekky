package ast.nodes;

class If extends Node {

    public final condition:Expression;
    public final consequence:Block;
    public final alternative:Block;

    public function new(position:Int, condition:Expression, consequence:Block, alternative:Block) {
        super(position, NodeType.If);

        this.condition = condition;
        this.consequence = consequence;
        this.alternative = alternative;
    }
}