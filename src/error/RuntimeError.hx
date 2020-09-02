package error;

import evaluator.ReturnAddress;
import compiler.debug.LocalVariableTable;
import compiler.debug.LineNumberTable;
import haxe.ds.GenericStack;

class RuntimeError {

    final callStack:GenericStack<ReturnAddress>;
    final lineNumberTable:LineNumberTable;
    final localVariableTable:LocalVariableTable;

    public function new(callStack:GenericStack<ReturnAddress>, lineNumberTable:LineNumberTable, localVariableTable:LocalVariableTable) {
        this.callStack = callStack;
        this.lineNumberTable = lineNumberTable;
        this.localVariableTable = localVariableTable;
    }

    function printHead(message:String) {
        Console.log('<#DE4A3F>error:</> $message.');
    }

    function printStackTrace() {
        while (!callStack.isEmpty()) {
            final returnAddress = callStack.pop();
            final position = lineNumberTable.resolve(returnAddress.byteIndex);
            final functionName = localVariableTable.resolve(returnAddress.calledFunction.index - 2 * 5);
            Console.log('   at ${functionName == null ? "[native]" : functionName } (???:${position.line}:${position.linePos + 1})');
        }

        Console.log("   at (global)");
    }

    public function error(message:String) {
        printHead(message);
        printStackTrace();

        Sys.exit(0);
    }
}