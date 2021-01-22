package error;

import vm.VirtualMachine;
import object.UserFunctionObj;
import object.Object;

class RuntimeError {

    final vm:VirtualMachine;

    public function new(vm:VirtualMachine) {
        this.vm = vm;
    }

    function printHead(message:String) {
        Console.log('<#DE4A3F>error:</> $message.');
    }

    function printStackTrace() {
        var position = vm.lineNumberTable.resolve(vm.instructions.position);
        var filename = vm.filenameTable.resolve(vm.instructions.position);

        while (!vm.frames.isEmpty()) {
            final frame = vm.popFrame();
            final functionPosition:Int = if (frame.calledFunction != null && frame.calledFunction.type == ObjectType.UserFunction) {
                final cUserFunction = cast(frame.calledFunction, UserFunctionObj);
                cUserFunction.position;
            } else {
                -1;
            }
            final functionName = vm.variableTable.resolve(functionPosition);
            Console.log('   at ${functionName == null ? "[anonymous]" : functionName } ($filename:${position.line}:${position.lineOffset + 1})');

            position = vm.lineNumberTable.resolve(frame.returnAddress);
            filename = vm.filenameTable.resolve(frame.returnAddress);
        }
    }

    public function error(message:String) {
        printHead(message);
        printStackTrace();

        ErrorHelper.exit();
    }
}