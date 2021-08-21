package event;

import event.message.*;

class EventLoop {

    final queue:Array<Message> = [];

    public function new() {}

    public function start() {
        while (queue.length > 0) {
            final current = queue.shift();
            if (current is Timable) {
                final timable = cast(current, Timable);
                if (timable.shouldExecute()) {
                    current.handler.call([]);
                }
                if (!timable.cleared) {
                    queue.push(current); 
                }  
            } else if (current is CallMessage) {
                current.handler.call([current.data]); 
            }
        }
    }

    public function enqueue(message:Message) {
        queue.push(message);
    }
}