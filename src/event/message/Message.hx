package event.message;

import object.ClosureObj;
import object.Object;

enum MessageType {
    Call;
    Interval;
    Timeout;
}

class Message {

    public final type:MessageType;
    public final handler:ClosureObj;
    public final data:Object;

    public function new(type:MessageType, handler:ClosureObj, data:Object) {
        this.type = type;
        this.handler = handler;
        this.data = data;
    }
}

/* class Event {

    public final name:String;
    public final object:Object;
    public final data:Object;

    public function new(object:Object, name:String, data:Object) {
        this.name = name;
        this.object = object;
        this.data = data;
    }
} */