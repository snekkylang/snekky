import haxe.io.Path;
import evaluator.Evaluator;
import compiler.Compiler;
import parser.Parser;
import lexer.Lexer;
import sys.io.File;

class Snekky {

    public static var filename:String;
    public static var code:String;
    
    public static function main() {
        final args = Sys.args();

        filename = args[0];

        final byteCode = if (Path.extension(filename) == "snek") {
            code = File.getContent('./$filename');

            final lexer = new Lexer(code);

            final parser = new Parser(lexer);
            parser.generateAst();

            final compiler = new Compiler();
            compiler.compile(parser.ast);

            compiler.getByteCode();
        } else {
            File.getBytes('./$filename'); 
        }

        final evaluator = new Evaluator(byteCode);
        evaluator.eval(); 
    }
}