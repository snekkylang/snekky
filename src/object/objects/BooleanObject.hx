package object.objects;
class BooleanObject extends Object {

    final value:Bool;

    public function new(value:Bool) {
        super(ObjectType.Boolean);

        this.value = value;
    }
}