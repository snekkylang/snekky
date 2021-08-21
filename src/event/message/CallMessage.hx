package event.message;

import object.Object;
import object.ClosureObj;

class CallMessage extends Message {

    public final handler:ClosureObj;

    public function new(handler:ClosureObj, data:Object) {
        super(data);

        this.handler = handler;
    }
}