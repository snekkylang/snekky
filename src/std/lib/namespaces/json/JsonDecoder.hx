package std.lib.namespaces.json;

import object.ArrayObj;
import object.BooleanObj;
import object.NullObj;
import object.StringObj;
import object.NumberObj;
import haxe.ds.StringMap;
import lexer.TokenType;
import vm.VirtualMachine;
import object.HashObj;
import lexer.Token;
import object.Object;
import lexer.Lexer;

class JsonDecoder {

    final vm:VirtualMachine;
    final lexer:Lexer;
    var currentToken:Token;
    
    public function new(json:String, vm:VirtualMachine) {
        this.vm = vm;

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

        return new HashObj(map, vm);
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

        return new ArrayObj(array, vm);
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
                final n = new NumberObj(Std.parseFloat(currentToken.literal), vm);
                nextToken();

                n;
            case TokenType.String:
                final s = new StringObj(currentToken.literal, vm);
                nextToken();

                s;
            case TokenType.Null:
                nextToken();
                new NullObj(vm);
            case TokenType.True:
                nextToken();
                new BooleanObj(true, vm);
            case TokenType.False:
                nextToken();
                new BooleanObj(false, vm);
            case TokenType.Minus:
                nextToken();
                final n = new NumberObj(-Std.parseFloat(currentToken.literal), vm);
                nextToken();

                n;
            default:
                throw 'failed to parse JSON. unexpected token ${currentToken.type}';
                null;
        }

        return o;
    }
}