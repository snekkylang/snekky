package object.objects;

class ArrayObj implements Object {

    public final type = ObjectType.Array;
    public final values:Array<ObjectWrapper> = [];

    public function new() {}

    function copyObject(obj:ObjectWrapper):ObjectWrapper {
        final value = switch (obj.object.type) {
            case ObjectType.Float: new FloatObj(cast(obj.object, FloatObj).value);
            case ObjectType.String: new StringObj(cast(obj.object, StringObj).value);
            default: obj.object;
        }

        return new ObjectWrapper(value);
    }

    public function unshift(obj:ObjectWrapper) {
        values.unshift(copyObject(obj));
    }

    public function push(obj:ObjectWrapper) {
        values.push(copyObject(obj));
    }

    public function set(index:Int, value:ObjectWrapper) {
        values[index] = value;
    }

    public function toString():String {
        return Std.string(values);
    }
}