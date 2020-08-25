package object.objects;

class IntObject extends Object {

    public final value:Int;

    public function new(value:Int) {
        super(ObjectType.Int);
        this.value = value;
    }
}