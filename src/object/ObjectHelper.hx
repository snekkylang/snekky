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

    public static macro function extract(value:ExprOf<EnumValue>, pattern:Expr):Expr {
        switch (pattern) {
            case macro $a => $b:
                return macro switch ($value) {
                    case $a: $b;
                    default: throw "no match";
                }
            default:
                throw new Error("Invalid enum value extraction pattern", pattern.pos);
        }
    }
}
