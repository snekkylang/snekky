package lexer;

class Helper {
    
    public static inline function isLinebreak(s:String):Bool {
        return ~/\r\n|\r|\n/.match(s);
    }

    public static inline function isAscii(s:String):Bool {
        return ~/^[a-zA-Z0-9_\$]+$/.match(s);
    }

    public static inline function isNumber(s:String):Bool {
        return ~/^[0-9]+$/.match(s);
    }

    public static inline function isHexChar(s:String):Bool {
        return ~/[a-fA-F0-9]/.match(s);
    }
}
