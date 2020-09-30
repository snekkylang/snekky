package object;

import haxe.ds.StringMap;

class ObjectHelper {

    public static function toString(obj:Object) {
        return switch (obj) {
            case Object.Float(value): Std.string(value);
            case Object.String(value): value;
            case Object.UserFunction(position): '#func($position, UserDefined)';
            case Object.BuiltInFunction(_): '#func(BuiltIn)';
            case Object.Array(values):
                final stringArray:Array<String> = [];
                for (value in values) {
                    stringArray.push(toString(value));
                }
                Std.string(stringArray);
            case Object.Hash(values):
                final stringMap:StringMap<String> = new StringMap();
                for (key => value in values) {
                    stringMap.set(key, toString(value));
                }
                Std.string(stringMap);
            case Object.Null: "null";
        }
    }
}