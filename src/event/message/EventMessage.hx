package event.message;

import object.Object;

class EventMessage extends Message {

    final target:Object;
    final name:String;
    final arguments:Array<Object>;

    public function new(eventLoop:EventLoop, target:Object, name:String, arguments:Array<Object>) {
        super(eventLoop);

        this.target = target;
        this.name = name;
        this.arguments = arguments;
    }

    override function execute() {
        final handlers = eventLoop.getEventListeners(target, name);

        for (h in handlers) {
            h.call(arguments);
        }

        super.execute();
    }
}