package lexer;

class Token {
    
    public final type:TokenType;
    public final line:Int;
    public final linePos:Int;
    public final filename:String;
    public final literal:String;

    public function new(type:TokenType, line:Int, linePos:Int, filename:String, literal:String) {
        this.type = type;
        this.line = line;
        this.linePos = linePos - literal.length;
        this.filename = filename;
        this.literal = literal;
    }
}
