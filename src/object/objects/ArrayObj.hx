package object.objects;

class ArrayObj implements Object {

    public final type = ObjectType.Array;
    public final values:Array<ObjectWrapper> = [];

    public function new() { }

    function cloneObject(obj:ObjectWrapper):ObjectWrapper {
        final clone = switch (obj.object.type) {
            case ObjectType.Float: new FloatObj(cast(obj.object, FloatObj).value);
            case ObjectType.String: new StringObj(cast(obj.object, StringObj).value);
            default: obj.object;
        }

        return new ObjectWrapper(clone);
    }

    public function unshift(obj:ObjectWrapper) {
        values.unshift(cloneObject(obj));
    }

    public function toString():String {
        return Std.string(values);   
    }
}