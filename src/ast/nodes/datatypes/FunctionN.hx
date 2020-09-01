package ast.nodes.datatypes;

class FunctionN extends Node {

    public final parameters:Array<Ident>;
    public final block:Block;

    public function new(position:Int, block:Block, parameters:Array<Ident>) {
        super(position, NodeType.Function);

        this.parameters = parameters;
        this.block = block;
    }
}