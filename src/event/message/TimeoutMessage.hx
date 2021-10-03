package event.message;

import sys.thread.Mutex;
import haxe.Timer;
import object.Object;
import object.ClosureObj;
import sys.thread.Thread;

class TimeoutMessage extends Message implements Timable {

    final timeout:Int;
    final callback:ClosureObj;
    final arguments:Array<Object>;
    var cleared = false;
    final mutex = new Mutex();

    public function new(timeout:Int, eventLoop:EventLoop, callback:ClosureObj, arguments:Array<Object>) {
        super(eventLoop);

        this.timeout = timeout;
        this.callback = callback;
        this.arguments = arguments;
    }

    override public function execute() {
        // Return instantly if interval has been cleared before event loop was started
        if (cleared) {
            eventLoop.unscheduleTask();
            return;
        }

        Thread.create(function() {
            final startTime = Timer.stamp() * 1000;

            while (Timer.stamp() * 1000 - startTime < timeout) {
                mutex.acquire();
                if (cleared) {
                    mutex.release();
                    eventLoop.unscheduleTask();
                    return;
                }
                mutex.release();

                Sys.sleep(1 / 1000);
            }

            eventLoop.scheduleCall(callback, arguments);
            eventLoop.unscheduleTask();
        });
    }

    public function clear() {
        cleared = true;
    }
}