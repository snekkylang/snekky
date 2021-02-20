package lexer;

import haxe.io.Path;

class Lexer {

    public final filename:String;
    public final code:String;
    var currentChar = ' ';
    var position = 0;
    var inString = false;
    var line = 1;
    var lineOffset = -1;

    public function new(filename:String, code:String) {
        this.filename = Path.normalize(filename);
        this.code = code;
    }

    function updateLinePosition() {
        if (~/\r\n|\n/.match(currentChar)) {
            line++;
            lineOffset = -1;
        } else {
            lineOffset++;
        }
    }

    function readChar() {
        currentChar = if (position >= code.length) {
            "\u{0}";
        } else {
            code.charAt(position);
        }

        updateLinePosition();
        position++;

        eatComment();
    }

    function peekChar():String {
        return (position >= code.length) ? "\u{0}" : code.charAt(position);
    }

    function peekCharN(n:Int):Array<String> {
        final lastPosition = position;
        final lastChar = currentChar;
        final lastLine = line;
        final lastLineOffset = lineOffset;
        final chars:Array<String> = [];
        for (_ in 0...n) {
            readChar();
            chars.push(currentChar);
        }
        position = lastPosition;
        currentChar = lastChar;
        line = lastLine;
        lineOffset = lastLineOffset;

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
            case "b": "\u0008";
            case "f": "\u000C";
            case "\\": "\\";
            case "/": "/";
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
        final lastPosition = position;
        final lastChar = currentChar;
        final lastLine = line;
        final lastLineOffset = lineOffset;
        final token = readToken();
        position = lastPosition;
        currentChar = lastChar;
        line = lastLine;
        lineOffset = lastLineOffset;

        return token;
    }

    public function peekTokenN(n:Int) {
        final lastPosition = position;
        final lastChar = currentChar;
        final lastLine = line;
        final lastLineOffset = lineOffset;
        final tokens:Array<Token> = [];
        for (_ in 0...n) {
            tokens.push(readToken());
        }
        position = lastPosition;
        currentChar = lastChar;
        line = lastLine;
        lineOffset = lastLineOffset;
        
        return tokens;
    }

    public function readToken():Token {
        readChar();
        eatWhitespace();

        final tokenPosition = new Position(position - 1, line, lineOffset);

        return switch (currentChar) {
            case "~":
                switch (peekChar()) {
                    case "/":
                        final regex = readRegex();
                        new Token(TokenType.Regex, tokenPosition, regex);
                    default: new Token(TokenType.BitNot, tokenPosition, "~");
                }
            case ".":
                switch (peekCharN(2)) {
                    case [".", "."]:
                        readChar();
                        readChar();
                        new Token(TokenType.ExclusiveRange, tokenPosition, "...");
                    case [".", _]:
                        readChar();
                        new Token(TokenType.InclusiveRange, tokenPosition, "..");
                    default: new Token(TokenType.Dot, tokenPosition, ".");
                }
            case ";": new Token(TokenType.Semicolon, tokenPosition, ";");
            case "(": new Token(TokenType.LParen, tokenPosition, "(");
            case ")": new Token(TokenType.RParen, tokenPosition, ")");
            case "{": new Token(TokenType.LBrace, tokenPosition, "{");
            case "}": new Token(TokenType.RBrace, tokenPosition, "}");
            case "[": new Token(TokenType.LBracket, tokenPosition, "[");
            case "]": new Token(TokenType.RBracket, tokenPosition, "]");
            case ",": new Token(TokenType.Comma, tokenPosition, ",");
            case "^": 
                if (peekChar() == "=") {
                    readChar();
                    new Token(TokenType.BitXorAssign, tokenPosition, "^=");
                } else new Token(TokenType.BitXor, tokenPosition, "^");
            case "+": 
                if (peekChar() == "=") {
                    readChar();
                    new Token(TokenType.PlusAssign, tokenPosition, "+=");
                } else new Token(TokenType.Plus, tokenPosition, "+");
            case "-": 
                if (peekChar() == "=") {
                    readChar();
                    new Token(TokenType.MinusAssign, tokenPosition, "-=");
                } else new Token(TokenType.Minus, tokenPosition, "-");
            case "/": new Token(TokenType.Slash, tokenPosition, "/");
                if (peekChar() == "=") {
                    readChar();
                    new Token(TokenType.SlashAssign, tokenPosition, "/=");
                } else new Token(TokenType.Slash, tokenPosition, "/");
            case "*": 
                if (peekChar() == "=") {
                    readChar();
                    new Token(TokenType.AsteriskAssign, tokenPosition, "*=");
                } else new Token(TokenType.Asterisk, tokenPosition, "*");
            case "%": 
                if (peekChar() == "=") {
                    readChar();
                    new Token(TokenType.PercentAssign, tokenPosition, "%=");
                } else new Token(TokenType.Percent, tokenPosition, "%");
            case ":": new Token(TokenType.Colon, tokenPosition, ":");
            case "\"": 
                final string = readString();
                new Token(TokenType.String, tokenPosition, string); // position - 2?
            case "&":
                switch (peekChar()) {
                    case "&":
                        readChar();
                        new Token(TokenType.And, tokenPosition, "&&");
                    case "=":
                        readChar();
                        new Token(TokenType.BitAndAssign, tokenPosition, "&=");
                    default: new Token(TokenType.BitAnd, tokenPosition, "&");
                }
            case "|":
                switch (peekChar()) {
                    case "|":
                        readChar();
                        new Token(TokenType.Or, tokenPosition, "||");
                    case "=":
                        readChar();
                        new Token(TokenType.BitOrAssign, tokenPosition, "|=");
                    default: new Token(TokenType.BitOr, tokenPosition, "|");
                }
            case "!":
                if (peekChar() == "=") {
                    readChar();
                    new Token(TokenType.NotEquals, tokenPosition, "!=");
                } else new Token(TokenType.Bang, tokenPosition, "!");
            case "=":
                switch (peekChar()) {
                    case "=":
                        readChar();
                        new Token(TokenType.Equals, tokenPosition, "==");
                    case ">":
                        readChar();
                        new Token(TokenType.Arrow, tokenPosition, "=>");
                    default: new Token(TokenType.Assign, tokenPosition, "=");
                }

            case "<":
                switch (peekChar()) {
                    case "=":
                        readChar();
                        new Token(TokenType.LessThanOrEqual, tokenPosition, "<=");
                    case "<":
                        readChar();
                        if (peekChar() == "=") {
                            readChar();
                            new Token(TokenType.BitShiftLeftAssign, tokenPosition, "<<=");
                        } else new Token(TokenType.BitShiftLeft, tokenPosition, "<<");
                    default: new Token(TokenType.LessThan, tokenPosition, "<");
                }
            case ">":
                switch (peekChar()) {
                    case "=":
                        readChar();
                        new Token(TokenType.GreaterThanOrEqual, tokenPosition, ">=");
                    case "<":
                        readChar();
                        new Token(TokenType.ConcatString, tokenPosition, "><");
                    case ">":
                        readChar();
                        if (peekChar() == "=") {
                            readChar();
                            new Token(TokenType.BitShiftRightAssign, tokenPosition, ">>=");
                        } else new Token(TokenType.BitShiftRight, tokenPosition, ">>");
                    default: new Token(TokenType.GreaterThan, tokenPosition, ">");
                }
            case "\u{0}": new Token(TokenType.Eof, tokenPosition, currentChar);
            default:
                if (Helper.isNumber(currentChar)) {
                    final number = readNumber();
                    return new Token(TokenType.Number, tokenPosition, number);
                }

                if (Helper.isAscii(currentChar)) {
                    final ident = readIdent();

                    if (Keyword.isKeyword(ident)) {
                        return new Token(Keyword.getKeyword(ident), tokenPosition, ident);
                    } else {
                        return new Token(TokenType.Ident, tokenPosition, ident);
                    }
                }

                return new Token(TokenType.Illegal, tokenPosition, currentChar);
        }
    }
}
