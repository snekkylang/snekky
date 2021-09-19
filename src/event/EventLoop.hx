package event;

import event.message.*;
import object.Object;
import object.ClosureObj;
import sys.thread.Deque;

class EventLoop {

    final queue = new Deque<Message>();
    var scheduledTasks = 0;
    final eventListeners:Map<Object, Map<String, Array<ClosureObj>>> = new Map();
    var shouldRun = false;

    public function new() {}

    public function start() {
        if (shouldRun) {
            do {
                final message = queue.pop(true);
    
                message.execute();
            } while (scheduledTasks > 0);
        }
    }

    public function enqueue(message:Message) {
        shouldRun = true;
        scheduleIncreaseTasks();
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

    public function scheduleDecreaseTasks():UnscheduleTaskMessage {
        final message = new UnscheduleTaskMessage(this);
        queue.add(message);

        return message; 
    }

    public function scheduleIncreaseTasks():ScheduleTaskMessage {
        final message = new ScheduleTaskMessage(this);
        queue.add(message);

        return message;
    }

    public function addEventListener(target, name, handler) {
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

    public function getEventListeners(target, name) {
        return try {
            eventListeners.get(target).get(name);
        } catch (err) {
            [];
        }
    }

    public function unscheduleTask() {
        scheduledTasks--;
    }

    public function scheduleTask() {
        scheduledTasks++;
    }
}