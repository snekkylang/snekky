package std.lib.namespaces;

import event.message.Timable;
import object.StringObj;
import object.NumberObj;
import object.NullObj;
import object.ClosureObj;
import object.Object.ObjectType;
import vm.VirtualMachine;

private class Future extends MemberObject {

    public function new(vm:VirtualMachine, promiseCallback:ClosureObj) {
        super(vm);

        addFunctionMember("handle", [ObjectType.Closure], function(p) {
            final handlerCallback = cast(p[0], ClosureObj);

            vm.eventLoop.scheduleCall(promiseCallback, [handlerCallback]);

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

            final message = vm.eventLoop.scheduleInterval(interval, cb, []);

            return new Timer(vm, message).getMembers();
        });

        addFunctionMember("scheduleTimeout", [ObjectType.Number, ObjectType.Closure], function(p) {
            final timeout = Std.int(cast(p[0], NumberObj).value);
            final cb = cast(p[1], ClosureObj);

            final message = vm.eventLoop.scheduleTimeout(timeout, cb, []);

            return new Timer(vm, message).getMembers();
        });

        addFunctionMember("attach", [null], function(p) {
            final target = p[0];

            target.addFunctionMember("attachEventListener", [ObjectType.String, ObjectType.Closure], function(p) {
                final eventName = cast(p[0], StringObj).value;
                final cb = cast(p[1], ClosureObj);

                vm.eventLoop.addEventListener(target, eventName, cb);

                return new NullObj(vm);
            });

            target.addFunctionMember("dispatchEvent", [ObjectType.String, null], function(p) {
                final eventName = cast(p[0], StringObj).value;
                final data = p[1];

                vm.eventLoop.scheduleEvent(target, eventName, [data]);

                return new NullObj(vm);
            });

            return new NullObj(vm);
        });
    }
}