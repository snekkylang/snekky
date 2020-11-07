package lexer;

import haxe.io.Path;

class Lexer {

    public final filename:String;
    public final code:String;
    var currentChar = ' ';
    var position = 0;
    var inString = false;

    public function new(filename:String, code:String) {
        this.filename = Path.normalize(filename);
        this.code = code;
    }

    function readChar() {
        currentChar = if (position >= code.length) {
            "\u{0}";
        } else {
            code.charAt(position);
        }

        position++;

        eatComment();
    }

    function peekChar():String {
        return (position >= code.length) ? "\u{0}" : code.charAt(position);
    }

    function peekCharN(n:Int):Array<String> {
        final lastPosition = position;
        final lastChar = currentChar;
        final chars:Array<String> = [];
        for (_ in 0...n) {
            readChar();
            chars.push(currentChar);
        }
        position = lastPosition;
        currentChar = lastChar;

        return chars;
    }

    function readIdent():String {
        final startPosition = position;

        while (Helper.isAscii(peekChar()) || peekChar() == "_") {
            readChar();
        }

        return code.substring(startPosition - 1, position);
    }

    function escapeChar():String {
        readChar();

        return switch (currentChar) {
            case "\"": "\"";
            case "t": "\t";
            case "n": "\n";
            case "r": "\r";
            case "\\": "\\";
            default: "";
        }
    }

    function readString():String {
        inString = true;
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

        inString = false;
        return string.toString();
    }

    function readRegex():String {
        inString = true;
        readChar();
        readChar();

        final regex = new StringBuf();

        while (currentChar != "/" && currentChar != "\u{0}") {
            if (currentChar == "\\") {
                readChar();
            }

            regex.add(currentChar);

            readChar();
        }

        inString = false;
        return regex.toString();
    }

    function readNumber():String {
        final startPosition = position;

        var peek = peekCharN(2);

        while (Helper.isNumber(peek[0]) || (peek[0] == "." && peek[1] != ".")) {
            readChar();
            peek = peekCharN(2);
        }

        return code.substring(startPosition - 1, position);
    }

    function eatWhitespace() {
        while (currentChar == " " || Helper.isLinebreak(currentChar) || currentChar == "\t") {
            readChar();
        }
    }

    function eatComment() {
        if (!inString && currentChar == "/" && peekChar() == "/") {
            while (!Helper.isLinebreak(currentChar) && currentChar != "\u{0}") {
                readChar();
            }
        }
    }

    public function tokenize() {
        while (currentChar != "\u{0}") {
            final token = readToken();
            trace('${token.position} ${token.type} ${token.literal}');
        }
    }

    public function peekToken():Token {
        final lastPostion = position;
        final token = readToken();
        position = lastPostion;

        return token;
    }

    public function peekTokenN(n:Int) {
        final lastPostion = position;
        final tokens:Array<Token> = [];
        for (_ in 0...n) {
            tokens.push(readToken());
        }
        position = lastPostion;
        
        return tokens;
    }

    public function readToken():Token {
        readChar();
        eatWhitespace();

        return switch (currentChar) {
            case "~":
                if (peekChar() == "/") {
                    final regex = readRegex();
                    new Token(TokenType.Regex, position, regex);
                } else {
                    new Token(TokenType.Tilde, position, "~");
                }
            case ".":
                switch (peekCharN(2)) {
                    case [".", "."]:
                        readChar();
                        readChar();
                        new Token(TokenType.ExclusiveRange, position, "...");
                    case [".", _]:
                        readChar();
                        new Token(TokenType.InclusiveRange, position, "..");
                    default: new Token(TokenType.Dot, position, ".");
                }
            case ";": new Token(TokenType.Semicolon, position, ";");
            case "(": new Token(TokenType.LParen, position, "(");
            case ")": new Token(TokenType.RParen, position, ")");
            case "{": new Token(TokenType.LBrace, position, "{");
            case "}": new Token(TokenType.RBrace, position, "}");
            case "[": new Token(TokenType.LBracket, position, "[");
            case "]": new Token(TokenType.RBracket, position, "]");
            case ",": new Token(TokenType.Comma, position, ",");
            case "+": 
                if (peekChar() == "=") {
                    readChar();
                    new Token(TokenType.PlusAssign, position, "+=");
                } else new Token(TokenType.Plus, position, "+");
            case "-": 
                if (peekChar() == "=") {
                    readChar();
                    new Token(TokenType.MinusAssign, position, "-=");
                } else new Token(TokenType.Minus, position, "-");
            case "/": new Token(TokenType.Slash, position, "/");
                if (peekChar() == "=") {
                    readChar();
                    new Token(TokenType.SlashAssign, position, "/=");
                } else new Token(TokenType.Slash, position, "/");
            case "*": 
                if (peekChar() == "=") {
                    readChar();
                    new Token(TokenType.AsteriskAssign, position, "*=");
                } else new Token(TokenType.Asterisk, position, "*");
            case "%": 
                if (peekChar() == "=") {
                    readChar();
                    new Token(TokenType.PercentAssign, position, "%=");
                } else new Token(TokenType.Percent, position, "%");
            case ":": new Token(TokenType.Colon, position, ":");
            case "\"": 
                final string = readString();
                new Token(TokenType.String, position - 2, string);
            case "&":
                if (peekChar() == "&") {
                    readChar();
                    new Token(TokenType.And, position, "&&");
                } else new Token(TokenType.BitAnd, position, "&");
            case "|":
                if (peekChar() == "|") {
                    readChar();
                    new Token(TokenType.Or, position, "|");
                } else new Token(TokenType.BitOr, position, "|");
            case "!":
                if (peekChar() == "=") {
                    readChar();
                    new Token(TokenType.NotEquals, position, "!=");
                } else new Token(TokenType.Bang, position, "!");
            case "=":
                switch (peekChar()) {
                    case "=":
                        readChar();
                        new Token(TokenType.Equals, position, "==");
                    case ">":
                        readChar();
                        new Token(TokenType.Arrow, position, "=>");
                    default: new Token(TokenType.Assign, position, "=");
                }

            case "<":
                if (peekChar() == "=") {
                    readChar();
                    new Token(TokenType.LessThanOrEqual, position, "<=");
                } else new Token(TokenType.LessThan, position, "<");
            case ">":
                switch (peekChar()) {
                    case "=":
                        readChar();
                        new Token(TokenType.GreaterThanOrEqual, position, ">=");
                    case "<":
                        readChar();
                        new Token(TokenType.ConcatString, position, "><");
                    default: new Token(TokenType.GreaterThan,position, ">");
                }
            case "\u{0}": new Token(TokenType.Eof, position, currentChar);
            default:
                if (Helper.isNumber(currentChar)) {
                    final number = readNumber();
                    return new Token(TokenType.Number, position, number);
                }

                if (Helper.isAscii(currentChar)) {
                    final ident = readIdent();

                    if (Keyword.isKeyword(ident)) {
                        return new Token(Keyword.getKeyword(ident), position, ident);
                    } else {
                        return new Token(TokenType.Ident, position, ident);
                    }
                }

                return new Token(TokenType.Illegal, position, currentChar);
        }
    }
}
