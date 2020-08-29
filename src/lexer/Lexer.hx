package lexer;

class Lexer {
    public final code:String;
    public final filename:String;
    var currentLine = 1;
    var currentLinePos = 0;
    var currentChar = ' ';
    var position = 0;

    public function new(code:String, filename:String) {
        this.code = ~/\r\n|\r|\n/g.replace(code, "\n");
        this.filename = filename;
    }

    function increaseCurrentLine() {
        if (Helper.isLinebreak(currentChar)) {
            currentLine++;
            currentLinePos = 0;
        }
    }

    function readChar() {
        increaseCurrentLine();
        currentChar = if (position >= code.length) {
            "\u{0}";
        } else {
            code.charAt(position);
        }

        currentLinePos++;
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
            case ".": new Token(TokenType.Dot, currentLine, currentLinePos, filename, ".");
            case ";": new Token(TokenType.Semicolon, currentLine, currentLinePos, filename, ";");
            case "(": new Token(TokenType.LParen, currentLine, currentLinePos, filename, "(");
            case ")": new Token(TokenType.RParen, currentLine, currentLinePos, filename, ")");
            case "{": new Token(TokenType.LBrace, currentLine, currentLinePos, filename, "{");
            case "}": new Token(TokenType.RBrace, currentLine, currentLinePos, filename, "}");
            case "[": new Token(TokenType.LBracket, currentLine, currentLinePos, filename, "[");
            case "]": new Token(TokenType.RBracket, currentLine, currentLinePos, filename, "]");
            case ",": new Token(TokenType.Comma, currentLine, currentLinePos, filename, ",");
            case "+": new Token(TokenType.Plus, currentLine, currentLinePos, filename, "+");
            case "-": new Token(TokenType.Minus, currentLine, currentLinePos, filename, "-");
            case "/": new Token(TokenType.Divide, currentLine, currentLinePos, filename, "/");
            case "*": new Token(TokenType.Multiply, currentLine, currentLinePos, filename, "*");
            case "%": new Token(TokenType.Modulo, currentLine, currentLinePos, filename, "%");
            case ":": new Token(TokenType.Colon, currentLine, currentLinePos, filename, ":");
            case "\"": 
                final string = readString();
                new Token(TokenType.String, currentLine, currentLinePos, filename, string);
            case "&":
                if (peekChar() == "&") {
                    readChar();
                    new Token(TokenType.LogicAnd, currentLine, currentLinePos, filename, "&&");
                } else new Token(TokenType.BitAnd, currentLine, currentLinePos, filename, "&");
            case "|":
                if (peekChar() == "|") {
                    readChar();
                    new Token(TokenType.LogicOr, currentLine, currentLinePos, filename, "|");
                } else new Token(TokenType.BitOr, currentLine, currentLinePos, filename, "|");
            case "!":
                if (peekChar() == "=") {
                    readChar();
                    new Token(TokenType.NotEqual, currentLine, currentLinePos, filename, "!=");
                } else new Token(TokenType.Bang, currentLine, currentLinePos, filename, "!");
            case "=":
                if (peekChar() == "=") {
                    readChar();
                    new Token(TokenType.Equal, currentLine, currentLinePos, filename, "==");
                } else new Token(TokenType.Assign, currentLine, currentLinePos, filename, "=");

            case "<":
                if (peekChar() == "=") {
                    readChar();
                    new Token(TokenType.SmallerThanOrEqual, currentLine, currentLinePos, filename, "<=");
                } else new Token(TokenType.SmallerThan, currentLine, currentLinePos, filename, "<");
            case ">":
                if (peekChar() == "=") {
                    readChar();
                    new Token(TokenType.GreaterThanOrEqual, currentLine, currentLinePos, filename, ">=");
                } else new Token(TokenType.GreaterThan, currentLine, currentLinePos, filename, ">");
            case "\u{0}": new Token(TokenType.Eof, currentLine, currentLinePos, filename, currentChar);
            default:
                if (Helper.isNumber(currentChar)) {
                    final number = readNumber();
                    return new Token(TokenType.Number, currentLine, currentLinePos, filename, number);
                }

                if (Helper.isAscii(currentChar)) {
                    final ident = readIdent();

                    if (Keyword.isKeyword(ident)) {
                        return new Token(Keyword.getKeyword(ident), currentLine, currentLinePos, filename, ident);
                    } else {
                        return new Token(TokenType.Ident, currentLine, currentLinePos, filename, ident);
                    }
                }

                return new Token(TokenType.Illegal, currentLine, currentLinePos, filename, currentChar);
        }
    }
}
