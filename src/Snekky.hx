import repl.Repl;
import haxe.io.Bytes;
import haxe.io.Path;
import evaluator.Evaluator;
import compiler.Compiler;
import parser.Parser;
import lexer.Lexer;

@:expose
class Snekky {

    public static inline final Version = "0.6.0";

    public static function compileString(filename:String, code:String, debug:Bool, compress:Bool):Bytes {
        final lexer = new Lexer(filename, code);

        final parser = new Parser(lexer, false);
        parser.generateAst();

        final compiler = new Compiler(debug);
        compiler.compile(parser.ast);
        final byteCode = compiler.getByteCode(compress);  

        return byteCode;
    }

    public static function evaluateBytes(byteCode:Bytes) {
        final evaluator = new Evaluator(byteCode);
        evaluator.eval();
    }
    
    public static function main() {
        #if target.sys
        final args = Sys.args();

        if (args.length == 0) {
            final repl = new Repl();
            repl.start();
        } else {
            final filename = args[0];
            final debug = !args.contains("--no-debug");
            final compress = args.contains("--dump") && !args.contains("--no-compress");
    
            if (Path.extension(filename) == "snek") {
                final code = sys.io.File.getContent('./$filename');
    
                final byteCode = compileString(filename, code, debug, compress);
    
                if (args.contains("--dump")) {
                    sys.io.File.saveBytes('${Path.withoutExtension(filename)}.bite', byteCode);
                    Sys.exit(0);
                }
    
                evaluateBytes(byteCode);
            } else {
                final byteCode = sys.io.File.getBytes('./$filename');
                evaluateBytes(byteCode);
            }
        }
        #end
    }
}