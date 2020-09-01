package object.objects;

class FloatObj extends Object {

    public final value:Float;

    public function new(value:Float) {
        super(ObjectType.Float);
        
        this.value = value;
    }
}