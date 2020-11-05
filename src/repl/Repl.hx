package repl;

import evaluator.Evaluator;
import compiler.Compiler;
import parser.Parser;
import lexer.Lexer;

class Repl {

    final compiler = new Compiler(true);
    var evaluator:Evaluator = null;

    public function new() {}

    function read():String {
        final code = new StringBuf();
        var openBraces = 0;
        var indented = false;

        inline function printIndentation() {
            if (openBraces != 0) {
                indented = true;
                Sys.print("    ... ");

                for (_ in 0...openBraces) {
                    Sys.print("    ");
                }
            } else if (indented) {
                indented = false;
                Sys.print("    ... ");
            } else {
                Sys.print("snekky> ");
            }
        }
        
        do {
            printIndentation();

            final line = Sys.stdin().readLine();

            openBraces -= line.split("").filter(c -> c == "}").length;

            Sys.print("\033[1A");
            Sys.print("\033[2K");
            printIndentation();
            Sys.println(line);

            openBraces += line.split("").filter(c -> c == "{").length;

            code.add(line);
        } while (openBraces != 0);

        return code.toString();
    }

    function handleCommand(line:String) {
        switch (line.substr(1)) {
            case "exit": 
                Sys.println("|  Goodbye");
                Sys.exit(0);
        }
    }

    public function start() {
        Sys.println('| Welcome to Snekky REPL -- Version ${Snekky.Version}');
        Sys.println("| type /exit to leave");
        Sys.println("");

        while (true) {
            final code = read();
            handleCommand(code);

            final lexer = new Lexer("repl", code);
            final parser = new Parser(lexer, true);
            parser.generateAst();

            compiler.compile(parser.ast);
            final byteCode = compiler.getByteCode(false);

            if (evaluator == null) {
                evaluator = new Evaluator(byteCode);
            } else {
                evaluator.newWithState(byteCode);
            }

            evaluator.eval();

            if (!evaluator.stack.isEmpty()) {
                Sys.println('==> ${evaluator.stack.pop()}');
            }
        }
    }
}