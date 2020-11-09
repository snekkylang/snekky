package std.lib.namespaces.json;

import object.BooleanObj;
import object.StringObj;
import haxe.iterators.ArrayIterator;
import object.ArrayObj;
import haxe.iterators.MapKeyValueIterator;
import object.HashObj;
import object.NumberObj;
import object.Object;

class JsonEncoder {

    public static function encode(object:Object) {
        final encoded = new StringBuf();

        switch (object.type) {
            case ObjectType.Number:
                final cNumber = cast(object, NumberObj);

                encoded.add(Std.string(cNumber));
            case ObjectType.Hash:
                final cHash = cast(object, HashObj);

                encoded.add("{");
                final iterator = new MapKeyValueIterator(cHash.value);
                for (k => v in iterator) {
                    encoded.add('"$k"');
                    encoded.add(": ");
                    encoded.add(encode(v));
                    if (iterator.hasNext()) {
                        encoded.add(", ");
                    }
                }
                
                encoded.add("}");
            case ObjectType.Array:
                final cArray = cast(object, ArrayObj);

                encoded.add("[");
                final iterator = new ArrayIterator(cArray.value);
                for (v in iterator) {
                    encoded.add(encode(v));
                    if (iterator.hasNext()) {
                        encoded.add(", ");
                    }
                }
                encoded.add("]");
            case ObjectType.String:
                final cString = cast(object, StringObj);

                encoded.add('"${cString.value}"');
            case ObjectType.Boolean:
                final cBoolean = cast(object, BooleanObj);

                encoded.add(cBoolean.value ? "true" : "false");
            case ObjectType.Null:
                encoded.add("null");
            default: throw 'failed to encode JSON. unsupported data type ${object.type}';
        }

        return encoded.toString();
    }
}