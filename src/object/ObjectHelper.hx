package object;

import object.objects.Object;
import object.objects.StringObj;
import object.objects.FloatObj;

class ObjectHelper {

    public static function cloneObject(obj:Object):Object {
        if (obj == null) {
            return obj;
        }

        final clone = switch (obj.type) {
            case ObjectType.Float: new FloatObj(cast(obj, FloatObj).value);
            case ObjectType.String: new StringObj(cast(obj, StringObj).value);
            default: obj;
        }

        return clone;
    }
}