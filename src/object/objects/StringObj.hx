package object.objects;

class StringObj implements Object {

    public final value:String;
    public final type = ObjectType.String;

    public function new(value:String) {        
        this.value = value;
    }

    public function toString():String {
        return value;
    }
}