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

        #if (playground != 1)
        filename = args[0];
        #else
        filename = "input.snek";
        #end
        final noDebug = args.contains("--no-debug");

        final byteCode = if (Path.extension(filename) == "snek") {
            #if (playground != 1)
            code = File.getContent('./$filename');
            #else
            code = args[0];
            #end

            final lexer = new Lexer(code);

            final parser = new Parser(lexer);
            parser.generateAst();

            final compiler = new Compiler(noDebug);
            compiler.compile(parser.ast);

            final byteCode = compiler.getByteCode();

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