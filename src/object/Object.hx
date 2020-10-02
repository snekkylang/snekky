package object;

import haxe.ds.StringMap;
import std.BuiltInTable.MemberFunction;

enum Object {
    Float(value:Float);
    String(value:String);
    UserFunction(position:Int, parametersCount:Int);
    BuiltInFunction(memberFunction:MemberFunction);
    Array(values:Array<Object>);
    Hash(values:StringMap<Object>);
    Null;
}