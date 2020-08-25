package parser.nodes;

class Statement extends Node {

    public final value:Expression;

    public function new(line:Int, value:Expression) {
        super(line, NodeType.Statement);

        this.value = value;
    }
}