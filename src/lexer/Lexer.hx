package lexer;

class Lexer {
    final code:String;
    var currentChar = ' ';
    var currentLine = 1;
    var position = 0;

    public function new(code:String) {
        this.code = ~/\r\n|\r|\n/.replace(code, "\n");
    }

    function increaseCurrentLine() {
        if (Helper.isLinebreak(currentChar) || position >= code.length) {
            currentLine++;
        }
    }

    function readChar() {
        currentChar = if (position >= code.length) {
            "\u{0}";
        } else {
            code.charAt(position);
        }

        position++;
    }

    function peekChar():String {
        return (position >= code.length) ? "\u{0}" : code.charAt(position);
    }

    function readIdent():String {
        final startPosition = position;

        while (Helper.isAscii(peekChar()) || peekChar() == "_") {
            readChar();
        }

        return code.substring(startPosition - 1, position);
    }

    function readString():String {
        return if (peekChar() == "\"") {
            readChar();
            "";
        } else {
            readChar();

            final startPosition = position;

            while (peekChar() != "\"" && peekChar() != "\u{0}") {
                readChar();
            }

            final string = code.substring(startPosition - 1, position);
            readChar();

            string;
        }
    }

    function readNumber():String {
        final startPosition = position;

        while (Helper.isNumber(peekChar()) || peekChar() == ".") {
            readChar();
        }

        return code.substring(startPosition - 1, position);
    }

    function eatWhitespace() {
        while (currentChar == " " || Helper.isLinebreak(currentChar)) {
            readChar();
            increaseCurrentLine();
        }
    }

    public function tokenize() {
        while (currentChar != "\u{0}") {
            final token = readToken();
            trace('${token.line} ${token.type} ${token.literal}');
        }
    }

    public function peekToken():Token {
        final lastPostion = position;
        final lastLine = currentLine;
        final token = readToken();
        position = lastPostion;
        currentLine = lastLine;

        return token;
    }

    public function readToken():Token {
        readChar();
        eatWhitespace();

        return switch (currentChar) {
            case ".": new Token(TokenType.Dot, currentLine, ".");
            case ";": new Token(TokenType.Semicolon, currentLine, ";");
            case "(": new Token(TokenType.LParen, currentLine, "(");
            case ")": new Token(TokenType.RParen, currentLine, ")");
            case "{": new Token(TokenType.LBrace, currentLine, "{");
            case "}": new Token(TokenType.RBrace, currentLine, "}");
            case "[": new Token(TokenType.LBracket, currentLine, "[");
            case "]": new Token(TokenType.RBracket, currentLine, "]");
            case ",": new Token(TokenType.Comma, currentLine, ",");
            case "+": new Token(TokenType.Plus, currentLine, "+");
            case "-": new Token(TokenType.Minus, currentLine, "-");
            case "/": new Token(TokenType.Divide, currentLine, "/");
            case "*": new Token(TokenType.Multiply, currentLine, "*");
            case "%": new Token(TokenType.Modulo, currentLine, "%");
            case ":": new Token(TokenType.Colon, currentLine, ":");
            case "\"": new Token(TokenType.String, currentLine, readString());
            case "&":
                if (peekChar() == "&") {
                    readChar();
                    new Token(TokenType.LogicAnd, currentLine, "&&");
                } else new Token(TokenType.BitAnd, currentLine, "&");
            case "|":
                if (peekChar() == "|") {
                    readChar();
                    new Token(TokenType.LogicOr, currentLine, "|");
                } else new Token(TokenType.BitOr, currentLine, "|");
            case "!":
                if (peekChar() == "=") {
                    readChar();
                    new Token(TokenType.NotEqual, currentLine, "!=");
                } else new Token(TokenType.Bang, currentLine, "!");
            case "=":
                if (peekChar() == "=") {
                    readChar();
                    new Token(TokenType.Equal, currentLine, "==");
                } else new Token(TokenType.Assign, currentLine, "=");

            case "<":
                if (peekChar() == "=") {
                    readChar();
                    new Token(TokenType.SmallerThanOrEqual, currentLine, "<=");
                } else new Token(TokenType.SmallerThan, currentLine, "<");
            case ">":
                if (peekChar() == "=") {
                    readChar();
                    new Token(TokenType.GreaterThanOrEqual, currentLine, ">=");
                } else new Token(TokenType.GreaterThan, currentLine, ">");
            case "\u{0}": new Token(TokenType.Eof, currentLine, currentChar);
            default:
                if (Helper.isNumber(currentChar)) {
                    return new Token(TokenType.Number, currentLine, readNumber());
                }

                if (Helper.isAscii(currentChar)) {
                    final ident = readIdent();

                    if (Keyword.isKeyword(ident)) {
                        return new Token(Keyword.getKeyword(ident), currentLine, ident);
                    } else {
                        return new Token(TokenType.Ident, currentLine, ident);
                    }
                }

                return new Token(TokenType.Illegal, currentLine, currentChar);
        }
    }
}
