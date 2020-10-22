package ast.nodes;

class DestructureHashNode extends Node {

    public final names:Array<String>;

    public function new(position:Int, names:Array<String>) {
        super(position, NodeType.DestructureHash);
        
        this.names = names;
    }
}