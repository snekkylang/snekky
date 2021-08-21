package event.message;

import object.ClosureObj;
import object.Object;

class Message {

    public final handler:ClosureObj;
    public final data:Object;

    public function new(handler:ClosureObj, data:Object) {
        this.handler = handler;
        this.data = data;
    }
}