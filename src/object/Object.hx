package object;

import std.BuiltInTable.MemberFunction;

enum Object {
    Float(value:Float);
    String(value:String);
    UserFunction(position:Int);
    BuiltInFunction(memberFunction:MemberFunction);
    Array(values:Array<Object>);
    Hash(values:Map<String, Object>);
    Null;
}