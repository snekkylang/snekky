package event.message;

class ScheduleTaskMessage extends Message {

    public function new(eventLoop:EventLoop) {
        super(eventLoop);
    }

    override function execute() {
        eventLoop.scheduleTask();
    }
}