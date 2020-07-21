package lexer;

class Token {

    public final type:TokenType;
    public final line:Int;
    public final literal:String;

    public function new(type:TokenType, line:Int, literal:String) {
        this.type = type;
        this.line = line;
        this.literal = literal;
    }
}