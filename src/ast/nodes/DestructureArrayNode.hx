package ast.nodes;

class DestructureArrayNode extends Node {

    public final names:Array<String>;

    public function new(position:Int, names:Array<String>) {
        super(position, NodeType.DestructureArray);
        
        this.names = names;
    }
}