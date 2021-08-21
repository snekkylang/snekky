package event.message;

import object.Object;
import object.ClosureObj;

class EventMessage extends Message {

    public final name:String;
    public final target:Object;

    public function new(name:String, target:Object, data:Object) {
        super(data);

        this.name = name;
        this.target = target;
    }
}