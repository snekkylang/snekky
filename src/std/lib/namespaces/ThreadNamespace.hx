package std.lib.namespaces;

import object.NumberObj;
import object.BooleanObj;
import object.Object;
import sys.thread.Lock;
import sys.thread.Thread;
import object.NullObj;
import object.ClosureObj;
import object.Object.ObjectType;
import vm.VirtualMachine;

class Channel extends MemberObject {

    public function new(vm:VirtualMachine) {
        super(vm);

        var message:Object = null;
        var lock:Lock = null;

        addFunctionMember("send", [null], function(p) {
            message = p[0];

            if (lock != null) {
                lock.release();
            }

            return new NullObj(vm);
        });

        addFunctionMember("receive", [ObjectType.Boolean], function(p) {
            final blocking = cast(p[0], BooleanObj).value;
            if (blocking && message == null) {
                lock = new Lock();
                lock.wait();
            }

            return message == null ? new NullObj(vm) : message;
        });
    }
}

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

            return new Channel(vm).getMembers();
        });
    }
}