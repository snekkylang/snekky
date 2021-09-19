package event.message;

class UnscheduleTaskMessage extends Message {

    public function new(eventLoop:EventLoop) {
        super(eventLoop);
    }

    override function execute() {
        eventLoop.unscheduleTask();
    }
}