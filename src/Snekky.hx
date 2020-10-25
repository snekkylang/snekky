import haxe.io.Bytes;
import haxe.io.Path;
import evaluator.Evaluator;
import compiler.Compiler;
import parser.Parser;
import lexer.Lexer;
#if target.sys
import sys.io.File;
#end

class Snekky {

    public static function compileString(filename:String, code:String, debug:Bool, compress:Bool):Bytes {
        final lexer = new Lexer(filename, code);

        final parser = new Parser(lexer);
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

        final filename = args[0];
        final debug = !args.contains("--no-debug");
        final compress = args.contains("--dump") && !args.contains("--no-compress");

        if (Path.extension(filename) == "snek") {
            final code = File.getContent('./$filename');

            final byteCode = compileString(filename, code, debug, compress);

            if (args.contains("--dump")) {
                File.saveBytes('${Path.withoutExtension(filename)}.bite', byteCode);
                Sys.exit(0);
            }

            evaluateBytes(byteCode);
        } else {
            final byteCode = File.getBytes('./$filename');
            evaluateBytes(byteCode);
        }
        #end
    }
}