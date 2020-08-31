package object.objects;

class FunctionObj extends Object {

    public final position:Int;

    public function new(position:Int) {
        super(ObjectType.Function);
        
        this.position = position;
    }
}