package object.objects;

class FunctionObj extends Object {

    public final index:Int;
    public final origin:ObjectOrigin;

    public function new(index:Int, origin:ObjectOrigin) {
        super(ObjectType.Function);
        
        this.index = index;
        this.origin = origin;
    }
}