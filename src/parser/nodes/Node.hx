package parser.nodes;

class Node {

    public final line:Int;
    public final type:NodeType;

    public function new(line:Int, type:NodeType) {
        this.line = line;
        this.type = type;
    }
}