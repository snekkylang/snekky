package error;

import object.UserFunctionObj;
import compiler.debug.FilenameTable;
import haxe.io.BytesInput;
import object.Object;
import evaluator.Frame;
import compiler.debug.LocalVariableTable;
import compiler.debug.LineNumberTable;
import haxe.ds.GenericStack;

class RuntimeError {

    final frames:GenericStack<Frame>;
    final lineNumberTable:LineNumberTable;
    final localVariableTable:LocalVariableTable;
    final filenameTable:FilenameTable;
    final byteCode:BytesInput;

    public function new(frames:GenericStack<Frame>, lineNumberTable:LineNumberTable, localVariableTable:LocalVariableTable, filenameTable:FilenameTable, byteCode:BytesInput) {
        this.frames = frames;
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
        var filename = filenameTable.resolve(byteCode.position);

        while (!frames.isEmpty()) {
            final frame = frames.pop();
            if (frame.calledFunction == null) {
                break;
            }
            final functionPosition:Int = if (frame.calledFunction.type == ObjectType.UserFunction) {
                final cUserFunction = cast(frame.calledFunction, UserFunctionObj);
                cUserFunction.position;
            } else {
                -1;
            }
            final functionName = localVariableTable.resolve(functionPosition - 2 * 5);
            Console.log('   at ${functionName == null ? "[anonymous]" : functionName } ($filename:${position.line}:${position.linePos + 1})');

            position = lineNumberTable.resolve(frame.returnAddress);
            filename = filenameTable.resolve(frame.returnAddress);
        }
    }

    public function error(message:String) {
        printHead(message);
        printStackTrace();

        Sys.exit(0);
    }
}