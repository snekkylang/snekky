package ast.nodes;

import lexer.Position;

class FileNode extends BlockNode {

    public final fileName:String;
    public final code:String;

    public function new(position:Position, fileName:String, code:String) {
        super(position);

        this.fileName = fileName;
        this.code = code;
        this.type = NodeType.File;
    }
}