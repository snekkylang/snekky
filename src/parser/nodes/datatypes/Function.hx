package parser.nodes.datatypes;

class FunctionN extends Node {

    public final parameters:Array<Ident>;
    public final block:Block;

    public function new(line:Int, block:Block, parameters:Array<Ident>) {
        this.line = line;
        this.type = NodeType.Function;
        this.parameters = parameters;
        this.block = block;
    }
}