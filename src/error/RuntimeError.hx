package error;

import haxe.ds.GenericStack;
import vm.Frame;
import object.StringObj;
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

    public function error(message:String) {
        final poppedFrames:Array<Frame> = [];

        var target = vm.errorTable.resolve(vm.instructions.position);
        while (!vm.frames.isEmpty()) {

            if (target != -1) {
                vm.pushStack(new StringObj(message, vm));
                vm.instructions.position = target;
                if (poppedFrames.length > 0) {
                    vm.frames.add(poppedFrames.pop());
                    vm.currentFrame = vm.frames.first();
                }
                return;
            }

            trace("ok");
            final frame = vm.popFrame();
            poppedFrames.push(frame);

            target = vm.errorTable.resolve(frame.returnAddress);
        }

        printHead(message);
        var position = vm.lineNumberTable.resolve(vm.instructions.position);
        var filename = vm.filenameTable.resolve(vm.instructions.position);

        for (frame in poppedFrames) {
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

        ErrorHelper.exit();
    }
}