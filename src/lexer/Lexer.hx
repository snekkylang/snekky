package lexer;

class Lexer {
    public final code:String;
    var currentChar = ' ';
    var position = 0;

    public function new(code:String) {
        this.code = code;
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
        final lastPostion = position;
        final token = readToken();
        position = lastPostion;

        return token;
    }

    public function readToken():Token {
        readChar();
        eatWhitespace();

        return switch (currentChar) {
            case ".": new Token(TokenType.Dot, position, ".");
            case ";": new Token(TokenType.Semicolon, position, ";");
            case "(": new Token(TokenType.LParen, position, "(");
            case ")": new Token(TokenType.RParen, position, ")");
            case "{": new Token(TokenType.LBrace, position, "{");
            case "}": new Token(TokenType.RBrace, position, "}");
            case "[": new Token(TokenType.LBracket, position, "[");
            case "]": new Token(TokenType.RBracket, position, "]");
            case ",": new Token(TokenType.Comma, position, ",");
            case "+": new Token(TokenType.Plus, position, "+");
            case "-": new Token(TokenType.Minus, position, "-");
            case "/": new Token(TokenType.Divide, position, "/");
            case "*": new Token(TokenType.Multiply, position, "*");
            case "%": new Token(TokenType.Modulo, position, "%");
            case ":": new Token(TokenType.Colon, position, ":");
            case "\"": 
                final string = readString();
                new Token(TokenType.String, position, string);
            case "&":
                if (peekChar() == "&") {
                    readChar();
                    new Token(TokenType.LogicAnd, position, "&&");
                } else new Token(TokenType.BitAnd, position, "&");
            case "|":
                if (peekChar() == "|") {
                    readChar();
                    new Token(TokenType.LogicOr, position, "|");
                } else new Token(TokenType.BitOr, position, "|");
            case "!":
                if (peekChar() == "=") {
                    readChar();
                    new Token(TokenType.NotEqual, position, "!=");
                } else new Token(TokenType.Bang, position, "!");
            case "=":
                if (peekChar() == "=") {
                    readChar();
                    new Token(TokenType.Equal, position, "==");
                } else new Token(TokenType.Assign, position, "=");

            case "<":
                if (peekChar() == "=") {
                    readChar();
                    new Token(TokenType.SmallerThanOrEqual, position, "<=");
                } else new Token(TokenType.SmallerThan, position, "<");
            case ">":
                if (peekChar() == "=") {
                    readChar();
                    new Token(TokenType.GreaterThanOrEqual, position, ">=");
                } else new Token(TokenType.GreaterThan,position, ">");
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
