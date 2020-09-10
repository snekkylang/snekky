package object;

import object.ObjectOrigin;

enum Object {
    Float(value:Float);
    String(value:String);
    Function(index:Int, origin:ObjectOrigin);
    Array(values:Array<Object>);
    Hash(values:Map<String, Object>);
}