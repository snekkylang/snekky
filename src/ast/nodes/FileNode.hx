package ast.nodes;

import lexer.Position;

class FileNode extends BlockNode {

    public final filename:String;
    public final code:String;

    public function new(position:Position, filename:String, code:String) {
        super(position);

        this.filename = filename;
        this.code = code;
        this.type = NodeType.File;
    }
}