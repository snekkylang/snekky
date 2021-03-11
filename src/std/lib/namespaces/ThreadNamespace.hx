package std.lib.namespaces;

import sys.thread.Lock;
import sys.thread.Thread;
import object.NullObj;
import object.ClosureObj;
import object.Object.ObjectType;
import vm.VirtualMachine;

class ThreadNamespace extends MemberObject {

    public static final name = "Thread";

    public function new(vm:VirtualMachine) {
        super(vm);

        addFunctionMember("run", [ObjectType.Closure], function(p) {
            final callback = cast(p[0], ClosureObj);
            final lock = new Lock();

            final newVirtualMachine = new VirtualMachine(vm.fileData);

            Thread.create(function() {
                newVirtualMachine.callFunction(callback, []);

                lock.release();
            });

            vm.addThreadLock(lock);

            return new NullObj(vm);
        });
    }
}