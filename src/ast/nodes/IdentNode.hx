package ast.nodes;

class IdentNode extends Node {

    public final value:String;

    public function new(position:Int, value:String) {
        super(position, NodeType.Ident);

        this.value = value;
    }
}