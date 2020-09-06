package object.objects;

class FloatObj implements Object {

    public final value:Float;
    public final type = ObjectType.Float;

    public function new(value:Float) {        
        this.value = value;
    }

    public function toString():String {
        return Std.string(value);
    }
}