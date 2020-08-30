package lexer;

class Token {
    
    public final type:TokenType;
    public final position:Int;
    public final literal:String;

    public function new(type:TokenType, position:Int, literal:String) {
        this.type = type;
        this.position = position - literal.length;
        this.literal = literal;
    }
}
