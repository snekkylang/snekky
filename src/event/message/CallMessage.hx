package event.message;

import event.message.Message.MessageType;
import object.Object;
import object.ClosureObj;

class CallMessage extends Message {

    public function new(handler:ClosureObj, data:Object) {
        super(MessageType.Call, handler, data);
    }
}