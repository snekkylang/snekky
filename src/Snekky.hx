import evaluator.Evaluator;
import compiler.Compiler;
import parser.Parser;
import lexer.Lexer;
import sys.io.File;

class Snekky {

    public static var filename:String;
    public static var code:String;
    
    public static function main() {
        filename = "input.snek";
        code = File.getContent("./input.snek");

        final lexer = new Lexer(code);

        final parser = new Parser(lexer);
        parser.generateAst();
        parser.writeAst(); 

        final compiler = new Compiler();
        compiler.compile(parser.ast);

        final evaluator = new Evaluator(compiler.getByteCode());
        evaluator.eval(); 
    }
}