package ast.nodes;

class Ident extends Node {

    public final value:String;

    public function new(position:Int, value:String) {
        super(position, NodeType.Ident);

        this.value = value;
    }
}