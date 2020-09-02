package error;

import compiler.LineNumberTable;
import haxe.ds.GenericStack;

class RuntimeError {

    static function printHead(message:String) {
        Console.log('<#DE4A3F>error:</> $message.');
    }

    static function printStackTrace(callStack:GenericStack<Int>, lineNumberTable:LineNumberTable) {
        while (!callStack.isEmpty()) {
            final returnAddress = callStack.pop();
            final position = lineNumberTable.resolve(returnAddress);
            Console.log('   at ? (?:${position.line}:${position.linePos + 1})');
        }

        Console.log("   at (global)");
    }

    public static function error(message:String, callStack:GenericStack<Int>, lineNumberTable:LineNumberTable) {
        printHead(message);
        printStackTrace(callStack, lineNumberTable);

        Sys.exit(0);
    }
}