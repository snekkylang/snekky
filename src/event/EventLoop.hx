package event;

import event.message.Message.MessageType;
import event.message.*;

class EventLoop {

    final queue:Array<Message> = [];

    public function new() {}

    public function start() {
        while (queue.length > 0) {
            final current = queue.shift();
            switch (current.type) {
                case MessageType.Call: current.handler.vm.callFunction(current.handler, [current.data]);
                case MessageType.Interval: // TODO: use interface for timeout and interval
                    final interval = cast(current, IntervalMessage);
                    if (interval.shouldExecute()) {
                        current.handler.vm.callFunction(current.handler, []);
                    }
                    if (!interval.cleared) {
                        queue.push(interval);
                    }
                case MessageType.Timeout:
                    final timeout = cast(current, TimeoutMessage);
                    if (timeout.shouldExecute()) {
                        current.handler.vm.callFunction(current.handler, []);
                    }
                    if (!timeout.cleared) {
                        queue.push(timeout); 
                    }
            }
        }
    }

    public function enqueue(message:Message) {
        queue.push(message);
    }
}