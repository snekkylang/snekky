package object.objects;

class FunctionObj implements Object {

    public final index:Int;
    public final origin:ObjectOrigin;
    public final type = ObjectType.Function;

    public function new(index:Int, origin:ObjectOrigin) {        
        this.index = index;
        this.origin = origin;
    }

    public function toString():String {
        return '#func($index, $origin)';
    }
}