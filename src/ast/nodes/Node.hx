package ast.nodes;

class Node {

    public final position:Int;
    public final type:NodeType;

    public function new(position:Int, type:NodeType) {
        this.position = position;
        this.type = type;
    }
}