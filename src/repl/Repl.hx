package repl;

import sys.io.FileSeek;
import sys.io.Process;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import sys.thread.Lock;
import error.ErrorHelper;
import sys.thread.Thread;
import vm.VirtualMachine;
import compiler.Compiler;
import parser.Parser;
import lexer.Lexer;

class Repl {
    var compiler = new Compiler(true);
    var vm:VirtualMachine = null;
    var thread:Thread;

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

    function handleCommand(line:String):Bool {
        if (!StringTools.startsWith(line, "/")) {
            return false;
        }

        switch (line.substr(1)) {
            case "exit":
                Console.log("Goodbye");
                Sys.exit(0);
            case "clear":
                Sys.print("\033c");
            case "reset" | "r":
                compiler = new Compiler(true);
                vm = null;
                Console.log("Environment reset");
            case "disassemble" | "d":
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
                    return true;
                }

                for (row in ~/\r\n|\n/g.split(process.stdout.readAll().toString())) {
                    if (row.length == 0) {
                        continue;
                    }

                    Console.log(row);
                }

                process.close();
            case "help":
                Console.log("help - Shows this dialogue.");
                Console.log("exit - Exits the REPL environment.");
                Console.log("clear - Clears the screen.");
                Console.log("reset/r - Resets the environment.");
                Console.log("disassemble/d - Prints the disassembled bytecode.");
            default:
                Console.log("Unknown command");
        }

        return true;
    }

    function handleInput() {
        final lock = new Lock();
        thread = Thread.create(() -> {
            ErrorHelper.exit = function() {
                lock.release();
                throw "execution failed";
            };

            try {
                final code = read();
                if (handleCommand(code)) {
                    lock.release();
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
                    Sys.println('==> ${vm.stack.pop()}');
                }
            } catch (e) {}

            lock.release();
        });

        lock.wait();
        handleInput();
    }

    public function start() {
        final lock = new Lock();

        Console.log('Welcome to Snekky REPL -- Version ${Snekky.Version}');
        Console.log("Type /help for more information");
        Sys.println("");

        handleInput();
        lock.wait();
    }
}
