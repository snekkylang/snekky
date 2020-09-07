package object;

import object.objects.StringObj;
import object.objects.FloatObj;

class ObjectHelper {

    public static function cloneObject(obj:ObjectWrapper):ObjectWrapper {
        if (obj.object == null) {
            return obj;
        }

        final clone = switch (obj.object.type) {
            case ObjectType.Float: new FloatObj(cast(obj.object, FloatObj).value);
            case ObjectType.String: new StringObj(cast(obj.object, StringObj).value);
            default: obj.object;
        }

        return new ObjectWrapper(clone);
    }
}