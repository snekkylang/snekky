package std.lib.namespaces;

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

private class Interval extends MemberObject {

    public function new(vm:VirtualMachine, message:IntervalMessage) {
        super(vm);

        addFunctionMember("clear", [], function(p) {
            message.clear();

            return new NullObj(vm);
        });
    }
}

private class Timeout extends MemberObject {

    public function new(vm:VirtualMachine, message:TimeoutMessage) {
        super(vm);

        addFunctionMember("clear", [], function(p) {
            message.clear();

            return new NullObj(vm);
        });
    }
}

class EventNamespace extends MemberObject {

    public static final name = "Event";

    public function new(vm:VirtualMachine) {
        super(vm);

        addFunctionMember("Future", [ObjectType.Closure], function(p) {
            final promiseCallback = cast(p[0], ClosureObj);

            return new Future(vm, promiseCallback).getMembers();
        });

        addFunctionMember("interval", [ObjectType.Number, ObjectType.Closure], function(p) {
            final interval = Std.int(cast(p[0], NumberObj).value);
            final cb = cast(p[1], ClosureObj);

            final message = new IntervalMessage(cb, interval);
            vm.eventLoop.enqueue(message);

            return new Interval(vm, message).getMembers();
        });

        addFunctionMember("timeout", [ObjectType.Number, ObjectType.Closure], function(p) {
            final timeout = Std.int(cast(p[0], NumberObj).value);
            final cb = cast(p[1], ClosureObj);

            final message = new TimeoutMessage(cb, timeout);
            vm.eventLoop.enqueue(message);

            return new Timeout(vm, message).getMembers();
        });
    }
}