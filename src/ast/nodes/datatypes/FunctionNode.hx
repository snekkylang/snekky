package ast.nodes.datatypes;

import lexer.Position;

class FunctionNode extends Node {

    public final parameters:Array<IdentNode>;
    public final block:BlockNode;

    public function new(position:Position, block:BlockNode, parameters:Array<IdentNode>) {
        super(position, NodeType.Function);

        this.parameters = parameters;
        this.block = block;
    }
}