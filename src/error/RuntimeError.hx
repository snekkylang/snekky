package error;

import evaluator.ReturnAddress;
import haxe.ds.GenericStack;

class RuntimeError {

    static function printHead(message:String) {
        Console.log('<#DE4A3F>error:</> $message.');
    }

    static function printStackTrace(callStack:GenericStack<ReturnAddress>) {
        while (!callStack.isEmpty()) {
            final returnAddress = callStack.pop();
            final func = returnAddress.calledFunction;
            Console.log('   at ${func.name} (${func.filename}:${func.line}:${func.linePos + 1})');
        }

        Console.log("   at (global)");
    }

    public static function error(message:String, callStack:GenericStack<ReturnAddress>) {
        printHead(message);
        printStackTrace(callStack);

        Sys.exit(0);
    }
}