package std.lib.namespaces.json;

import object.ArrayObj;
import object.BooleanObj;
import object.NullObj;
import object.StringObj;
import object.NumberObj;
import haxe.ds.StringMap;
import lexer.TokenType;
import evaluator.Evaluator;
import object.HashObj;
import lexer.Token;
import object.Object;
import lexer.Lexer;

class JsonDecoder {

    final evaluator:Evaluator;
    final lexer:Lexer;
    var currentToken:Token;
    
    public function new(json:String, evaluator:Evaluator) {
        this.evaluator = evaluator;

        lexer = new Lexer("json_decoder", json);
        currentToken = lexer.readToken();
    }

    function nextToken() {
        currentToken = lexer.readToken();
    }

    function parseHash():HashObj {
        nextToken();

        final map:StringMap<Object> = new StringMap();

        while (currentToken.type != TokenType.RBrace) {
            assertToken(TokenType.String, "String");
            final key = currentToken.literal;
            nextToken();
            assertToken(TokenType.Colon, "`:`");
            nextToken();
            final value = decode();

            if (currentToken.type == TokenType.Comma) {
                if (lexer.peekToken().type == TokenType.RBrace) {
                    throw "failed to parse JSON. illegal trailing comma";
                }
                nextToken();
            }

            map.set(key, value);
        }

        nextToken();

        return new HashObj(map, evaluator);
    }

    function parseArray():ArrayObj {
        nextToken();

        final array:Array<Object> = [];

        while (currentToken.type != TokenType.RBracket) {
            array.push(decode());
            
            if (currentToken.type == TokenType.Comma) {
                if (lexer.peekToken().type == TokenType.RBracket) {
                    throw "failed to parse JSON. illegal trailing comma";
                }

                nextToken();
            }
        }

        nextToken();

        return new ArrayObj(array, evaluator);
    }

    function assertToken(type:TokenType, expected:String) {
        if (currentToken.type != type) {
            throw 'failed to parse JSON. got ${currentToken.type}, expected $expected';
        }
    }

    public function decode() {
        final o = switch (currentToken.type) {
            case TokenType.LBrace: parseHash();
            case TokenType.LBracket: parseArray();
            case TokenType.Number: 
                final n = new NumberObj(Std.parseFloat(currentToken.literal), evaluator);
                nextToken();

                n;
            case TokenType.String:
                final s = new StringObj(currentToken.literal, evaluator);
                nextToken();

                s;
            case TokenType.Null:
                nextToken();
                new NullObj(evaluator);
            case TokenType.True:
                nextToken();
                new BooleanObj(true, evaluator);
            case TokenType.False:
                nextToken();
                new BooleanObj(false, evaluator);
            default:
                throw "failed to parse JSON. unsupported datatype";
                null;
        }

        return o;
    }
}