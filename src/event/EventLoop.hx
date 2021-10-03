package event;

import sys.thread.Mutex;
import event.message.*;
import object.Object;
import object.ClosureObj;
import sys.thread.Deque;

class EventLoop {

    final queue = new Deque<Message>();
    var scheduledTasks = 0;
    final eventListeners:Map<Object, Map<String, Array<ClosureObj>>> = new Map();
    final mutex = new Mutex();

    public function new() {}

    public function start() {
        if (scheduledTasks <= 0) {
            return;
        }

        while (true) {
            final message = queue.pop(true);
    
            message.execute();
        }
    }

    public function enqueue(message:Message) {
        scheduleTask();
        queue.add(message);
    }

    public function scheduleTimeout(timeout:Int, callback:ClosureObj, arguments:Array<Object>):TimeoutMessage {
        final message = new TimeoutMessage(timeout, this, callback, arguments);
        enqueue(message);

        return message;
    }

    public function scheduleInterval(interval:Int, callback:ClosureObj, arguments:Array<Object>):IntervalMessage {
        final message = new IntervalMessage(interval, this, callback, arguments);
        enqueue(message);

        return message;
    }

    public function scheduleEvent(target:Object, name:String, arguments:Array<Object>):EventMessage {
        final message = new EventMessage(this, target, name, arguments);
        enqueue(message);

        return message;
    }

    public function scheduleCall(callback:ClosureObj, arguments:Array<Object>):CallMessage {
        final message = new CallMessage(this, callback, arguments);
        enqueue(message);

        return message;
    }

    public function addEventListener(target:Object, name:String, handler:ClosureObj) {
        if (!eventListeners.exists(target)) {
            eventListeners.set(target, new Map());
        }
        final targetEvents = eventListeners.get(target);
        if (!targetEvents.exists(name)) {
            targetEvents.set(name, []);
        }
        final targetHandlers = targetEvents.get(name);
        targetHandlers.push(handler);
    }

    public function getEventListeners(target:Object, name:String) {
        return try {
            eventListeners.get(target).get(name);
        } catch (err) {
            [];
        }
    }

    public function unscheduleTask() {
        mutex.acquire();
        scheduledTasks--;
        if (scheduledTasks <= 0) {
            Sys.exit(0);
        }
        mutex.release();
    }

    public function scheduleTask() {
        mutex.acquire();
        scheduledTasks++;
        mutex.release();
    }
}