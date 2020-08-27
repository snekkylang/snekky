import evaluator.Evaluator;
import compiler.Compiler;
import parser.Parser;
import lexer.Lexer;
import sys.io.File;

class Snekky {
    
    public static function main() {
        final code = File.getContent("./input.snek");

        final lexer = new Lexer(code);

        final parser = new Parser(lexer);
        parser.generateAst();
        parser.writeAst();

        final compiler = new Compiler();
        compiler.compile(parser.ast);
        compiler.writeByteCode();

        final evaluator = new Evaluator(compiler.instructions.getBytes(), compiler.constants);
        evaluator.eval();
    }
}