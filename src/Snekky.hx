import haxe.io.Path;
import evaluator.Evaluator;
import compiler.Compiler;
import parser.Parser;
import lexer.Lexer;
import sys.io.File;

class Snekky {
    
    public static function main() {
        final args = Sys.args();

        #if (playground != 1)
        final filename = args[0];
        #else
        final filename = "input.snek";
        #end
        final noDebug = args.contains("--no-debug");
        final noCompress = args.contains("--no-compress");

        final byteCode = if (Path.extension(filename) == "snek") {
            #if (playground != 1)
            final code = File.getContent('./$filename');
            #else
            final code = args[0];
            #end

            final lexer = new Lexer(filename, code);

            final parser = new Parser(lexer);
            parser.generateAst();

            final compiler = new Compiler(noDebug);
            compiler.compile(parser.ast);

            final byteCode = compiler.getByteCode(!noCompress);

            if (args.contains("--dump")) {
                File.saveBytes('${Path.withoutExtension(filename)}.bite', byteCode);
                Sys.exit(0);
            }

            byteCode;
        } else {
            File.getBytes('./$filename'); 
        }

        final evaluator = new Evaluator(byteCode);
        evaluator.eval(); 
    }
}