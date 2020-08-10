package parser.nodes.operators;

class RParen extends Operator {

    public function new(line:Int) {
        this.line = line;
        this.type = NodeType.RParen;
    }
}