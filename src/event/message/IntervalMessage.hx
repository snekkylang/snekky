package event.message;

import sys.thread.Mutex;
import haxe.Timer;
import object.Object;
import object.ClosureObj;
import sys.thread.Thread;

class IntervalMessage extends Message implements Timable {

    final interval:Int;
    final callback:ClosureObj;
    final arguments:Array<Object>;
    var cleared = false;
    final mutex = new Mutex();

    public function new(interval:Int, eventLoop:EventLoop, callback:ClosureObj, arguments:Array<Object>) {
        super(eventLoop);

        this.interval = interval;
        this.callback = callback;
        this.arguments = arguments;
    }

    override function execute() {
        // Return instantly if interval has been cleared before event loop was started
        if (cleared) {
            eventLoop.unscheduleTask();
            return;
        }

        Thread.create(function() {
            while (true) {
                final startTime = Timer.stamp() * 1000;

                while (Timer.stamp() * 1000 - startTime < interval) {
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
            }
        });
    }

    public function clear() {
        cleared = true;
    }
}