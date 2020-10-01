package ast.nodes;

class FileNode extends BlockNode {

    public final filename:String;
    public final code:String;

    public function new(position:Int, filename:String, code:String) {
        super(position);

        this.filename = filename;
        this.code = code;
        this.type = NodeType.File;
    }
}