package event.message;

import object.Object;
import object.ClosureObj;

class CallMessage extends Message {

    public function new(handler:ClosureObj, data:Object) {
        super(handler, data);
    }
}