package ast.nodes.datatypes;

class FunctionNode extends Node {

    public final parameters:Array<IdentNode>;
    public final block:BlockNode;

    public function new(position:Int, block:BlockNode, parameters:Array<IdentNode>) {
        super(position, NodeType.Function);

        this.parameters = parameters;
        this.block = block;
    }
}