package object;

import haxe.iterators.MapKeyValueIterator;
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
                final buffer = new StringBuf();
                buffer.add("{");
                final iterator = new MapKeyValueIterator(values);
                for (k => v in iterator) {
                    buffer.add(k);
                    buffer.add(": ");
                    buffer.add(toString(v));
                    if (iterator.hasNext()) {
                        buffer.add(", ");
                    }
                }
                
                buffer.add("}");
                buffer.toString();
            case Object.Null: "null";
        }
    }
}