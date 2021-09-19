package event.message;

class Message {

    final eventLoop:EventLoop;

    public function new(eventLoop:EventLoop) {
        this.eventLoop = eventLoop;
    }

    public function execute() {
        eventLoop.scheduleDecreaseTasks();
    }
}