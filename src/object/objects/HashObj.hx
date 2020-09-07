package object.objects;

class HashObj implements Object {
  
    public final type = ObjectType.Hash;
    public final values:Map<String, ObjectWrapper> = new Map();

    public function new() { }

    public function set(key:String, value:ObjectWrapper) {
        values.set(key, ObjectHelper.cloneObject(value));
    }

    public function get(key:String):ObjectWrapper {
        final value = values.get(key);

        return if (value == null) {
            final wrapper = new ObjectWrapper(null);
            set(key, wrapper);

            wrapper;
        } else {
            value;
        }
    }

    public function toString():String {
        return values.toString();
    }
}