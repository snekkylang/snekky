package lexer;

class Helper {
    
    public static function isLinebreak(s:String) {
        return ~/\r\n|\r|\n/.match(s);
    }

    public static function isAscii(s:String) {
        return ~/^[a-zA-Z0-9_]*$/.match(s);
    }

    public static function isNumber(s:String) {
        return ~/^[0-9]+$/.match(s);
    }
}
