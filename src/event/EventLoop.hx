package event;

import object.ClosureObj;
import object.Object;
import event.message.*;

class EventLoop {

    final queue:Array<Message> = [];
    final eventListeners:Map<Object, Map<String, Array<ClosureObj>>> = new Map();

    public function new() {}

    public function start() {
        while (queue.length > 0) {
            final current = queue.shift();
            if (current is Timable) {
                final timable = cast(current, Timable);
                if (timable.shouldExecute()) {
                    timable.handler.call([]);
                }
                if (!timable.cleared) {
                    queue.push(current); 
                }  
            } else if (current is CallMessage) {
                final call = cast(current, CallMessage);
                call.handler.call([current.data]); 
            } else if (current is EventMessage) {
                final event = cast(current, EventMessage);
                
                try {
                    final handlers = eventListeners.get(event.target).get(event.name);
                    for (h in handlers) {
                        h.call([event.data]);
                    }
                } catch (e) {}
            }
        }
    }

    public function enqueue(message:Message) {
        queue.push(message);
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
}