package object.objects;

class StringObj extends Object {

    public final value:String;

    public function new(value:String) {
        super(ObjectType.String);
        
        this.value = value;
    }
}