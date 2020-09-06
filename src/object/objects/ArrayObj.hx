package object.objects;

class ArrayObj implements Object {

    public final type = ObjectType.Array;
    public final values:Array<ObjectWrapper> = [];

    public function new() {}

    public function unshift(obj:ObjectWrapper) {
        final value = switch (obj.object.type) {
            case ObjectType.Float: new FloatObj(cast(obj.object, FloatObj).value);
            case ObjectType.String: new StringObj(cast(obj.object, StringObj).value);
            default: obj.object;
        }

        values.unshift(new ObjectWrapper(value));
    }

    public function toString():String {
        return Std.string(values);
    }
}