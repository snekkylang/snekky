package object.objects;

import haxe.Int64;

class IntObject extends Object {

    public final value:Int64;

    public function new(value:Int64) {
        super(ObjectType.Int);
        this.value = value;
    }
}