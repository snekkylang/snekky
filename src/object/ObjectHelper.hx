package object;

import haxe.macro.Expr;

class ObjectHelper {

    public static function cloneObject(obj:Object):Object {
        if (obj == null) {
            return obj;
        }

        final clone = switch (obj) {
            case Object.Float(value): Object.Float(value);
            case Object.String(value): Object.String(value);
            default: obj;
        }

        return clone;
    }
}
