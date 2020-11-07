package repl;

import error.ErrorHelper;
import sys.thread.Thread;
import evaluator.Evaluator;
import compiler.Compiler;
import parser.Parser;
import lexer.Lexer;

class Repl {

    final compiler = new Compiler(true);
    var evaluator:Evaluator = null;
    var thread:Thread;

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

            final line = try {
                Sys.stdin().readLine();
            } catch (e) {
                Sys.exit(0);
                null;
            };

            openBraces -= line.split("").filter(c -> c == "}").length;

            Sys.print("\033[1A");
            Sys.print("\033[2K");
            printIndentation();
            Console.log(Highlighter.highlight(line));

            openBraces += line.split("").filter(c -> c == "{").length;

            code.add(line);
        } while (openBraces != 0);

        return code.toString();
    }

    function handleCommand(line:String):Bool {
        if (!StringTools.startsWith(line, "/")) {
            return false;
        }

        switch (line.substr(1)) {
            case "exit": 
                Sys.println("|  Goodbye");
                Sys.exit(0);
            case "clear":
                Sys.print("\033[2J");
            case "help":
                Sys.println("| help - Shows this dialoge.");
                Sys.println("| exit - Exists the REPL environment.");
                Sys.println("| clear - Clears the screen.");
            default: Sys.println("| Unknown command");
        }

        return true;
    }

    function handleInput() {
        thread = Thread.create(() -> {
            while (true) {
                final code = read();
                if (handleCommand(code)) {
                    continue;
                }

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
        });   

        Sys.sleep(-1);
    }

    public function start() {
        Sys.println('| Welcome to Snekky REPL -- Version ${Snekky.Version}');
        Sys.println("| Type /help for more information");
        Sys.println("");

        ErrorHelper.exit = function() {
            handleInput();
        };

        handleInput();
    }
}