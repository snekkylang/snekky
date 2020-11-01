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

    public static function resolvePosition(code:String, position:Int):{line:Int, linePos:Int} {
        var line = 1;
        var linePos = 0;

        for (i in 0...position) {
            if (~/\r\n|\n/.match(code.charAt(i))) {
                line++;
                linePos = 0;
            } else {
                linePos++; 
            }
        }
        
        return {
            line: line,
            linePos: linePos
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