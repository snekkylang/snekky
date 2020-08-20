package parser;

import parser.nodes.datatypes.Function.FunctionN;
import parser.nodes.datatypes.Int.IntN;
import sys.io.File;
import haxe.format.JsonPrinter;
import lexer.TokenType;
import lexer.Token;
import lexer.Lexer;
import parser.nodes.*;

class Parser {

    final lexer:Lexer;
    final expressionParser:ExpressionParser;
    public var ast = new Block(1);
    public var currentToken:Token;
    
    public function new(lexer:Lexer) {
        this.lexer = lexer;
        this.expressionParser = new ExpressionParser(this, lexer);
        this.currentToken = lexer.readToken();
    }

    public function generateAst() {
        while (currentToken.type != TokenType.Eof) {
            parseToken(ast);
            nextToken();
        }
    }

    public function writeAst() {
        File.saveContent("ast.json", JsonPrinter.print(ast));
    }

    public function nextToken() {
        currentToken = lexer.readToken();
    }

    @:nullSafety(Off)
    public function parseNumber():Node {
        final n = Std.parseInt(currentToken.literal);

        return new IntN(currentToken.line, n);
    }

    public function parseBlock():Block {
        final block = new Block(currentToken.line);

        while (currentToken.type != TokenType.RBrace) {
            if (currentToken.type == TokenType.Eof) {
                Error.unexpectedEof();
            }

            parseToken(block);
            nextToken();
        }

        return block;
    }

    public function parseFunction():FunctionN {
        if (currentToken.type != TokenType.LParen) {
            Error.unexpectedToken();
        }

        nextToken();

        final parameters:Array<Ident> = [];

        while (currentToken.type != TokenType.RParen) {
            if (currentToken.type == TokenType.Ident) {
                parameters.push(new Ident(currentToken.line, currentToken.literal));
            } else if (currentToken.type != TokenType.Comma) {
                Error.unexpectedToken();
            }

            nextToken();
        }

        nextToken();

        if (currentToken.type != TokenType.RParen) {
            Error.unexpectedToken();
        }

        nextToken();

        final block = parseBlock();

        return new FunctionN(currentToken.line, block, parameters);
    }

    public function parseCall(target:Expression):Expression {
        final callParameters:Array<Expression> = [];

        nextToken();

        while (currentToken.type != TokenType.RParen) {
            callParameters.push(expressionParser.parseExpression());
        }

        final call = new Expression(currentToken.line, new FunctionCall(currentToken.line, target, callParameters));

        return if (lexer.peekToken().type == TokenType.LParen) {
            nextToken();
            parseCall(call);
        } else {
            call;
        }
    }

    function parseVariable():Variable {
        var mutable = currentToken.type == TokenType.Mut;

        if (lexer.peekToken().type != TokenType.Ident) {
            Error.unexpectedToken();
        }

        nextToken();

        final name = currentToken.literal;

        if (lexer.peekToken().type != TokenType.Assign) {
            Error.unexpectedToken();
        }

        nextToken();
        nextToken();

        final value = expressionParser.parseExpression();

        return new Variable(currentToken.line, name, value, mutable);
    }

    public function parseToken(block:Block) {
        switch (currentToken.type) {
            case TokenType.Let | TokenType.Mut: block.addNode(parseVariable());
            default:
                block.addNode(expressionParser.parseExpression());
        }
    }
}