package object;

enum Object {
    Float(value:Float);
    String(value:String);
    UserFunction(position:Int);
    BuiltInFunction(index:Int);
    Array(values:Array<Object>);
    Hash(values:Map<String, Object>);
}