package parser.nodes;

class If extends Node {

    public final condition:Expression;
    public final consequence:Block;
    public final alternative:Block;

    public function new(line:Int, condition:Expression, consequence:Block, alternative:Block) {
        this.line = line;
        this.type = NodeType.If;
        this.condition = condition;
        this.consequence = consequence;
        this.alternative = alternative;
    }
}