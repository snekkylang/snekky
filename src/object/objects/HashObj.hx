package object.objects;

class HashObj implements Object {
  
    public final type = ObjectType.Hash;
    public final values:Map<String, Object> = new Map();

    public function new() { }

    public function set(key:String, value:Object) {
        values.set(key, ObjectHelper.cloneObject(value));
    }

    public function get(key:String):Object {
        return values.get(key);
    }

    public function toString():String {
        return values.toString();
    }
}