package std.lib.namespaces;

import event.message.Timable;
import event.message.TimeoutMessage;
import event.message.IntervalMessage;
import object.NumberObj;
import event.message.CallMessage;
import object.NullObj;
import object.ClosureObj;
import object.Object.ObjectType;
import vm.VirtualMachine;

private class Future extends MemberObject {

    public function new(vm:VirtualMachine, promiseCallback:ClosureObj) {
        super(vm);

        addFunctionMember("handle", [ObjectType.Closure], function(p) {
            final handlerCallback = cast(p[0], ClosureObj);

            vm.eventLoop.enqueue(new CallMessage(promiseCallback, handlerCallback));

            return new NullObj(vm);
        });
    }
}

private class Timer extends MemberObject {

    public function new(vm:VirtualMachine, message:Timable) {
        super(vm);

        addFunctionMember("clear", [], function(p) {
            message.clear();

            return new NullObj(vm);
        });
    }
}

class EventLoopNamespace extends MemberObject {

    public static final name = "EventLoop";

    public function new(vm:VirtualMachine) {
        super(vm);

        addFunctionMember("Future", [ObjectType.Closure], function(p) {
            final promiseCallback = cast(p[0], ClosureObj);

            return new Future(vm, promiseCallback).getMembers();
        });

        addFunctionMember("scheduleInterval", [ObjectType.Number, ObjectType.Closure], function(p) {
            final interval = Std.int(cast(p[0], NumberObj).value);
            final cb = cast(p[1], ClosureObj);

            final message = new IntervalMessage(cb, interval);
            vm.eventLoop.enqueue(message);

            return new Timer(vm, message).getMembers();
        });

        addFunctionMember("scheduleTimeout", [ObjectType.Number, ObjectType.Closure], function(p) {
            final timeout = Std.int(cast(p[0], NumberObj).value);
            final cb = cast(p[1], ClosureObj);

            final message = new TimeoutMessage(cb, timeout);
            vm.eventLoop.enqueue(message);

            return new Timer(vm, message).getMembers();
        });
    }
}