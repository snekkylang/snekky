package std.lib.namespaces;

import object.NumberObj;
import object.Object;
import sys.thread.Lock;
import sys.thread.Thread;
import object.NullObj;
import object.ClosureObj;
import object.Object.ObjectType;
import evaluator.Evaluator;

class Channel extends MemberObject {

    public function new(evaluator:Evaluator) {
        super(evaluator);

        var message:Object = null;
        var lock:Lock = null;

        addFunctionMember("send", 1, function(p) {
            message = p[0];

            if (lock != null) {
                lock.release();
            }

            return new NullObj(evaluator);
        });

        addFunctionMember("receive", 1, function(p) {
            assertParameterType(p[0], ObjectType.Number);
            final blocking = cast(p[0], NumberObj).value != 0;
            if (blocking && message == null) {
                lock = new Lock();
                lock.wait();
            }

            return message == null ? new NullObj(evaluator) : message;
        });
    }
}

class ThreadNamespace extends MemberObject {

    public static final name = "Thread";

    public function new(evaluator:Evaluator) {
        super(evaluator);

        addFunctionMember("run", 1, function(p) {
            assertParameterType(p[0], ObjectType.Closure);
            final callback = cast(p[0], ClosureObj);
            final lock = new Lock();

            final newEvaluator = new Evaluator(evaluator.fileData);

            Thread.create(function() {
                newEvaluator.callFunction(callback, []);

                lock.release();
            });

            evaluator.addThreadLock(lock);

            return new Channel(evaluator).getMembers();
        });
    }
}