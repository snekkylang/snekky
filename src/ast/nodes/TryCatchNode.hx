package ast.nodes;

import lexer.Position;

class TryCatchNode extends Node {

    public final body:BlockNode;
    public final catchBody:BlockNode;
    public final catchVariable:IdentNode;

    public function new(position:Position, body:BlockNode, catchBody:BlockNode, catchVariable:IdentNode) {
        super(position, NodeType.TryCatch);

        this.body = body;
        this.catchBody = catchBody;
        this.catchVariable = catchVariable;
    }
}