package event.message;

import object.Object;
import object.ClosureObj;
import sys.thread.Deque;
import sys.thread.Thread;

private enum ThreadMessage {
    Cancel;
}

class IntervalMessage extends Message implements Timable {

    final interval:Int;
    final callback:ClosureObj;
    final arguments:Array<Object>;
    var cancelled = false;
    var threadQueue = new Deque<ThreadMessage>();

    public function new(interval:Int, eventLoop:EventLoop, callback:ClosureObj, arguments:Array<Object>) {
        super(eventLoop);

        this.interval = interval;
        this.callback = callback;
        this.arguments = arguments;
    }

    override function execute() {
        Thread.create(function() {
            while (true) {
                if (threadQueue.pop(false) == ThreadMessage.Cancel) {
                    eventLoop.scheduleDecreaseTasks();
                    break;
                }

                Sys.sleep(interval / 1000);

                if (threadQueue.pop(false) == ThreadMessage.Cancel) {
                    eventLoop.scheduleDecreaseTasks();
                    break;
                }

                eventLoop.scheduleCall(callback, arguments);
            }
        });
    }

    public function cancel() {
        threadQueue.add(ThreadMessage.Cancel);
    }
}