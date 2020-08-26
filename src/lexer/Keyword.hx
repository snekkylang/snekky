package lexer;

class Keyword {

    static final keywords = [
        "func" => TokenType.Function, 
        "let" => TokenType.Let, 
        "mut" => TokenType.Mut, 
        "true" => TokenType.True, 
        "false" => TokenType.False,
        "if" => TokenType.If, 
        "else" => TokenType.Else, 
        "while" => TokenType.While, 
        "return" => TokenType.Return, 
        "import" => TokenType.Import,
        "break" => TokenType.Break,
    ];

    public static function isKeyword(ident:String):Bool {
        return keywords.get(ident) != null;
    }

    public static function getKeyword(ident:String):TokenType {
        return keywords[ident];
    }
}
