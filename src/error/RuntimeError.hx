package error;

import haxe.io.BytesInput;
import object.Object;
import evaluator.ReturnAddress;
import compiler.debug.LocalVariableTable;
import compiler.debug.LineNumberTable;
import haxe.ds.GenericStack;

using object.ObjectHelper;

class RuntimeError {

    final callStack:GenericStack<ReturnAddress>;
    final lineNumberTable:LineNumberTable;
    final localVariableTable:LocalVariableTable;
    final byteCode:BytesInput;

    public function new(callStack:GenericStack<ReturnAddress>, lineNumberTable:LineNumberTable, localVariableTable:LocalVariableTable, byteCode:BytesInput) {
        this.callStack = callStack;
        this.lineNumberTable = lineNumberTable;
        this.localVariableTable = localVariableTable;
        this.byteCode = byteCode;
    }

    function printHead(message:String) {
        Console.log('<#DE4A3F>error:</> $message.');
    }

    function printStackTrace() {
        var position = lineNumberTable.resolve(byteCode.position);

        while (!callStack.isEmpty()) {
            final returnAddress = callStack.pop();
            final functionIndex:Int = returnAddress.calledFunction.extract(Object.Function(index, _) => index);
            final functionName = localVariableTable.resolve(functionIndex - 2 * 5);
            Console.log('   at ${functionName == null ? "[native]" : functionName } (???:${position.line}:${position.linePos + 1})');

            position = lineNumberTable.resolve(returnAddress.byteIndex);
        }

        Console.log('   at [global] (???:${position.line}:${position.linePos + 1})');
    }

    public function error(message:String) {
        printHead(message);
        printStackTrace();

        Sys.exit(0);
    }
}