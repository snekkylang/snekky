package std.lib.namespaces.json.lexer;

import lexer.Helper;

class Lexer {

    final json:String;
    var currentChar = ' ';
    var position = 0;

    public function new(json:String) {
        this.json = json;
    }

    function readChar() {
        currentChar = if (position >= json.length) {
            "\u{0}";
        } else {
            json.charAt(position);
        }

        position++;
    }

    function peekChar():String {
        return (position >= json.length) ? "\u{0}" : json.charAt(position);
    }

    function escapeChar():String {
        readChar();

        return switch (currentChar) {
            case "\"": "\"";
            case "t": "\t";
            case "n": "\n";
            case "r": "\r";
            case "b": "\u0008";
            case "f": "\u000C";
            case "\\": "\\";
            case "/": "/";
            default: "";
        }
    }

    function readString():String {
        readChar();

        final string = new StringBuf();

        while (currentChar != "\"" && currentChar != "\u{0}") {
            if (currentChar == "\\") {
                string.add(escapeChar());
            } else {
                string.add(currentChar);
            }

            readChar();
        }

        return string.toString();
    }

    function readNumber():String {
        final startPosition = position;

        while (Helper.isNumber(peekChar()) || peekChar() == ".") {
            readChar();
        }

        return json.substring(startPosition - 1, position);
    }

    function readIdent():String {
        final startPosition = position;

        while (Helper.isAscii(peekChar())) {
            readChar();
        }

        return json.substring(startPosition - 1, position);
    }


    function eatWhitespace() {
        while (currentChar == " " || Helper.isLinebreak(currentChar) || currentChar == "\t") {
            readChar();
        }
    }

    public function tokenize() {
        while (currentChar != "\u{0}") {
            final token = readToken();
            trace('${token.position} ${token.type} ${token.literal}');
        }
    }

    public function peekToken():Token {
        final lastPosition = position;
        final lastChar = currentChar;
        final token = readToken();
        position = lastPosition;
        currentChar = lastChar;

        return token;
    }

    public function readToken():Token {
        readChar();
        eatWhitespace();

        return switch (currentChar) {
            case "{": new Token(TokenType.LBrace, position, "{");
            case "}": new Token(TokenType.RBrace, position, "}");
            case "[": new Token(TokenType.LBracket, position, "[");
            case "]": new Token(TokenType.RBracket, position, "]");
            case ",": new Token(TokenType.Comma, position, ",");
            case "-": new Token(TokenType.Minus, position, "-");
            case ":": new Token(TokenType.Colon, position, ":");
            case "\"": 
                final string = readString();
                new Token(TokenType.String, position, string); 
            case "\u{0}": new Token(TokenType.Eof, position, currentChar);
            default:
                if (Helper.isNumber(currentChar)) {
                    final number = readNumber();
                    return new Token(TokenType.Number, position, number);
                }

                if (Helper.isAscii(currentChar)) {
                    final ident = readIdent();

                    switch (ident) {
                        case "null": return new Token(TokenType.Null, position, "null");
                        case "true": return new Token(TokenType.True, position, "true");
                        case "false": return new Token(TokenType.False, position, "false");
                    }
                }

                return new Token(TokenType.Illegal, position, currentChar);
        }
    }
}