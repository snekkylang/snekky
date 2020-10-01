package error;

import compiler.debug.FilenameTable;
import haxe.io.BytesInput;
import object.Object;
import evaluator.ReturnAddress;
import compiler.debug.LocalVariableTable;
import compiler.debug.LineNumberTable;
import haxe.ds.GenericStack;

class RuntimeError {

    final callStack:GenericStack<ReturnAddress>;
    final lineNumberTable:LineNumberTable;
    final localVariableTable:LocalVariableTable;
    final filenameTable:FilenameTable;
    final byteCode:BytesInput;

    public function new(callStack:GenericStack<ReturnAddress>, lineNumberTable:LineNumberTable, localVariableTable:LocalVariableTable, filenameTable:FilenameTable, byteCode:BytesInput) {
        this.callStack = callStack;
        this.lineNumberTable = lineNumberTable;
        this.localVariableTable = localVariableTable;
        this.filenameTable = filenameTable;
        this.byteCode = byteCode;
    }

    function printHead(message:String) {
        Console.log('<#DE4A3F>error:</> $message.');
    }

    function printStackTrace() {
        var position = lineNumberTable.resolve(byteCode.position);
        final filename = filenameTable.resolve(byteCode.position);

        while (!callStack.isEmpty()) {
            final returnAddress = callStack.pop();
            final functionPosition:Int = switch (returnAddress.calledFunction) {
                case Object.UserFunction(position): position;
                default: -1;
            }
            final functionName = localVariableTable.resolve(functionPosition - 2 * 5);
            Console.log('   at ${functionName == null ? "[native]" : functionName } ($filename:${position.line}:${position.linePos + 1})');

            position = lineNumberTable.resolve(returnAddress.byteIndex);
        }

        Console.log('   at [global] ($filename:${position.line}:${position.linePos + 1})');
    }

    public function error(message:String) {
        printHead(message);
        printStackTrace();

        Sys.exit(0);
    }
}