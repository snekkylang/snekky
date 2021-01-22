package lexer;

class Token {
    
    public final type:TokenType;
    public final position:Position;
    public final literal:String;

    public function new(type:TokenType, position:Position, literal:String) {
        this.type = type;
        this.position = position;
        this.literal = literal;
    }
}
