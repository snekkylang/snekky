package event.message;

import object.Object;
import object.ClosureObj;

class CallMessage extends Message {

    final callback:ClosureObj;
    final arguments:Array<Object>;

    public function new(eventLoop:EventLoop, callback:ClosureObj, arguments:Array<Object>) {
        super(eventLoop);

        this.callback = callback;
        this.arguments = arguments;
    }

    override function execute() {
        callback.call(arguments);
        super.execute();
    }
}