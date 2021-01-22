package error;

class ErrorHelper {

    public static function repeatString(length:Int, s:String):String {
        final buffer = new StringBuf();

        for (_ in 0...length) {
            buffer.add(s);
        }

        return buffer.toString();
    }

    public static function clamp(min:Int, max:Int, value:Int):Int {
        return if (value < min) {
            min;
        } else if (value > max) {
            max;
        } else {
            value;
        }
    }

    public static dynamic function exit() {
        #if target.sys
        Sys.exit(0);
        #else
        throw "";
        #end
    }
}