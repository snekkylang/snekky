package object.objects;

class ArrayObj implements Object {

    public final type = ObjectType.Array;
    public final values:Array<Object> = [];

    public function new() { }

    public function unshift(obj:Object) {
        values.unshift(ObjectHelper.cloneObject(obj));
    }

    public function push(obj:Object) {
        values.push(ObjectHelper.cloneObject(obj));
    }

    public function toString():String {
        return Std.string(values);   
    }
}