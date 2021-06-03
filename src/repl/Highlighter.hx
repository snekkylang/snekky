package repl;

import lexer.Token;
import lexer.Lexer;
import lexer.TokenType;

private enum abstract TokenColor(String) {
    final Keyword1 = "5499D2";
    final Keyword2 = "C586C0";
    final Ident = "9CDCFE";
    final Closure = "4EC9B0";
    final Call = "DCDCAA";
    final String = "CE9178";
    final Number = "B5CEA8";
    final Default = "D4D4D4";
}

class Highlighter {

    public static function highlight(code:String) {
        Console.logPrefix = "";

        final lexer = new Lexer("repl", code);

        final highlightedCode = new StringBuf();

        inline function highlightToken(token:Token, color:TokenColor):String {
            return '<#$color>${code.substr(token.position.position, token.literal.length)}${code.substring(token.position.position + token.literal.length, lexer.peekToken().position.position)}</>';
        }

        while (true) {
            final token = lexer.readToken();

            if (token.type == TokenType.Eof) {
                break;
            }

            final highlighted = switch (token.type) {
                case TokenType.Let | TokenType.Mut | TokenType.In | TokenType.True | TokenType.False | TokenType.Function | TokenType.Null: 
                    highlightToken(token, TokenColor.Keyword1);
                case TokenType.If | TokenType.Else | TokenType.While | TokenType.Break | TokenType.Continue | TokenType.Return | TokenType.For | TokenType.When | TokenType.Import:
                    highlightToken(token, TokenColor.Keyword2);
                case TokenType.Ident:
                    if (~/^[A-Z][a-z]+(?:[A-Z][a-z]+)*$/.match(token.literal)) {
                        highlightToken(token, TokenColor.Closure);
                    } else if (lexer.peekToken().type == TokenType.LParen) {
                        highlightToken(token, TokenColor.Call);
                    } else {
                        highlightToken(token, TokenColor.Ident);
                    }
                case TokenType.String:
                    highlightToken(token, TokenColor.String);
                case TokenType.Number:
                    highlightToken(token, TokenColor.Number);
                default: highlightToken(token, TokenColor.Default);
            }

            highlightedCode.add(highlighted);
        }

        if (!StringTools.startsWith(code, "/")) {
            Console.log(highlightedCode.toString());
        } else {
            Console.println(code);
        }
        Console.logPrefix = "|  ";
    }
}