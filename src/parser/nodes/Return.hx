package parser.nodes;

class Return extends Node {

    public final value:Expression;

    public function new(line:Int, value:Expression) {
        super(line, NodeType.Return);

        this.value = value;
    }
}