package repl;

import hxargs.Args;
import build.Version;
import sys.io.Process;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import error.ErrorHelper;
import vm.VirtualMachine;
import compiler.Compiler;
import parser.Parser;
import lexer.Lexer;

class Repl {

    var compiler = new Compiler(true, true);
    var vm:VirtualMachine = null;

    public function new() {
        Console.logPrefix = "|  ";
    }

    function read():String {
        final code = new StringBuf();
        var openBraces = 0;
        var indented = false;

        inline function printIndentation() {
            if (openBraces > 0) {
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
            Highlighter.highlight(line);

            openBraces += line.split("").filter(c -> c == "{").length;

            code.add(line);
        } while (openBraces > 0);

        return code.toString();
    }

    function handleCommand(cmd:String) {
        var showHelp = false;
        final argumentHandler = Args.generate([
            @doc("Shows this dialog")
            ["/help"] => function() {
                showHelp = true;
            },
            @doc("Exits the REPL environment")
            ["/exit"] => function() {
                Console.log("Goodbye");
                Sys.exit(0);
            },
            @doc("Clears the screen")
            ["/clear"] => function() {
                Sys.print("\033c");
            },
            @doc("Resets the environment")
            ["/reset", "/r"] => function() {
                compiler = new Compiler(true, true);
                vm = null;
                Console.log("Environment reset");
            },
            @doc("Prints the disassembled bytecode")
            ["/disassemble", "/d"] => function() {
                final byteCode = compiler.getByteCode(false);
                final tempDir = if (Sys.systemName() == "Windows") {
                    Sys.getEnv("temp");
                } else {
                    "/tmp";
                }
                final file = '$tempDir/snekky/repl/dump/${Sys.time()}.bite';
                FileSystem.createDirectory(Path.directory(file));
                File.saveBytes(file, byteCode);

                final process = new Process('snekkyp $file');
                if (process.stderr.readAll().length > 0) {
                    Console.log("Snekkyp not found!");
                    return;
                }

                for (row in ~/\r\n|\n/g.split(process.stdout.readAll().toString())) {
                    if (row.length == 0) {
                        continue;
                    }

                    Console.log(row);
                }

                process.close();
            },
            _ => function(input:String) {
                showHelp = true;
            }
        ]);

        final command = cmd.split(" ");
        argumentHandler.parse(command);
        if (showHelp) {
            for (line in argumentHandler.getDoc().split("\n")) {
                Console.log(line);
            }
        }
    }

    function handleInput() {
        try {
            ErrorHelper.exit = function() {
                throw "execution failed";
            };

            final code = read();

            if (StringTools.startsWith(code, "/")) {
                handleCommand(code);
                return;
            }

            final lexer = new Lexer("repl", code);
            final parser = new Parser(lexer, true);
            parser.generateAst();

            compiler.compile(parser.ast);
            final byteCode = compiler.getByteCode(false);

            if (vm == null) {
                vm = new VirtualMachine(byteCode);
            } else {
                vm.newWithState(byteCode);
            }

            vm.eval();

            if (!vm.stack.isEmpty()) {
                Sys.println('==> ${vm.popStack()}');
            }
        } catch (e) {}

        handleInput();
    }

    public function start() {
        Console.log('Welcome to Snekky REPL -- Version ${Version.SemVersion}');
        Console.log("Type /help for more information");
        Sys.println("");

        handleInput();
    }
}
