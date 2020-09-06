package object;

import object.objects.Object;

class ObjectWrapper {

    public var object:Object;

    public function new(object:Object) {
        this.object = object;
    }

    public function toString():String {
        return object.toString();
    }
}