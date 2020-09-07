package object.objects;

class ArrayObj implements Object {

    public final type = ObjectType.Array;
    public final values:Array<ObjectWrapper> = [];

    public function new() { }

    public function unshift(obj:ObjectWrapper) {
        values.unshift(ObjectHelper.cloneObject(obj));
    }

    public function push(obj:ObjectWrapper) {
        values.push(ObjectHelper.cloneObject(obj));
    }

    public function toString():String {
        return Std.string(values);   
    }
}