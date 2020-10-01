package ast.nodes;

class Node {

    public final position:Int;
    public var type(default, null):NodeType;

    public function new(position:Int, type:NodeType) {
        this.position = position;
        this.type = type;
    }
}