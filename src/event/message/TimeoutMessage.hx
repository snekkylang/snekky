package event.message;

import object.Object;
import object.ClosureObj;
import sys.thread.Deque;
import sys.thread.Thread;

private enum ThreadMessage {
    Cancel;
}

class TimeoutMessage extends Message implements Timable {

    final timeout:Int;
    final callback:ClosureObj;
    final arguments:Array<Object>;
    var cancelled = false;
    var threadQueue = new Deque<ThreadMessage>();

    public function new(timeout:Int, eventLoop:EventLoop, callback:ClosureObj, arguments:Array<Object>) {
        super(eventLoop);

        this.timeout = timeout;
        this.callback = callback;
        this.arguments = arguments;
    }

    override public function execute() {
        Thread.create(function() {
            if (threadQueue.pop(false) == ThreadMessage.Cancel) {
                eventLoop.scheduleDecreaseTasks();
                return;
            }

            Sys.sleep(timeout / 1000);

            eventLoop.scheduleCall(callback, arguments);
            eventLoop.scheduleDecreaseTasks();
        });
    }

    public function cancel() {
        threadQueue.add(ThreadMessage.Cancel);
    }
}