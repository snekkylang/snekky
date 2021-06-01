package ast.nodes.datatypes;

import lexer.Position;

class ParameterNode extends Node {

    public final ident:IdentNode;
    public final mutable:Bool;

    public function new(position:Position, ident:IdentNode, mutable:Bool) {
        super(position, NodeType.Parameter);

        this.ident = ident;
        this.mutable = mutable;
    }
}

class FunctionNode extends Node {

    public final parameters:Array<ParameterNode>;
    public final block:BlockNode;

    public function new(position:Position, block:BlockNode, parameters:Array<ParameterNode>) {
        super(position, NodeType.Function);

        this.parameters = parameters;
        this.block = block;
    }
}