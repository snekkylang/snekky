package parser.nodes;

class Return extends Node {

    public final value:Expression;

    public function new(line:Int, value:Expression) {
        this.line = line;
        this.value = value;
        this.type = NodeType.Return;
    }
}