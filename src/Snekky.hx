import sys.io.File;
import lexer.Lexer;
import parser.Parser;

class Snekky {
    
    public static function main() {
        var code = File.getContent("./input.snek");

        var lexer = new Lexer(code);
        var parser = new Parser(lexer);
        parser.generateAst();
        parser.writeAst();
    }
}