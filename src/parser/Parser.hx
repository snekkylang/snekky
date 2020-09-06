package parser;

import error.CompileError;
import ast.nodes.datatypes.*;
import sys.io.File;
import haxe.format.JsonPrinter;
import lexer.TokenType;
import lexer.Token;
import lexer.Lexer;
import ast.nodes.*;

class Parser {

    final lexer:Lexer;
    final expressionParser:ExpressionParser;
    public var ast = new Block(1);
    public var currentToken:Token;
    
    public function new(lexer:Lexer) {
        this.lexer = lexer;

        expressionParser = new ExpressionParser(this, lexer);
        currentToken = lexer.readToken();
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

    public function parseNumber():Node {
        final nodePos = currentToken.position;
        final n = Std.parseFloat(currentToken.literal);
        return new FloatN(nodePos, n);
    }

    function parseBlock():Block {
        nextToken();
        
        final block = new Block(currentToken.position);

        while (currentToken.type != TokenType.RBrace) {
            if (currentToken.type == TokenType.Eof) {
                CompileError.unexpectedEof(currentToken);
            }

            parseToken(block);
            nextToken();
        }

        return block;
    }

    public function parseFunction():FunctionN {
        final nodePos = currentToken.position;

        assertToken(TokenType.LParen, "`(`");

        nextToken();

        final parameters:Array<Ident> = [];

        while (currentToken.type != TokenType.RParen) {
            if (currentToken.type == TokenType.Ident) {
                parameters.push(new Ident(currentToken.position, currentToken.literal));
                if (lexer.peekToken().type != TokenType.Comma && lexer.peekToken().type != TokenType.RParen) {
                    CompileError.unexpectedToken(currentToken, "comma or closing parenthesis");
                }
            } else if (currentToken.type == TokenType.Comma && lexer.peekToken().type == TokenType.RParen) {
                CompileError.unexpectedToken(currentToken, "identifier or `)`");
            } else {
                assertToken(TokenType.Comma, "identifier");
            }

            nextToken();
        }

        nextToken();

        assertToken(TokenType.LBrace, "`{`");

        final block = parseBlock();

        nextToken();

        return new FunctionN(nodePos, block, parameters);
    }

    public function parseCall(target:Expression):Expression {
        final nodePos = currentToken.position;

        nextToken();

        final callParameters:Array<Expression> = [];

        while (currentToken.type != TokenType.RParen) {
            callParameters.push(expressionParser.parseExpression());
            if (currentToken.type == TokenType.Comma && lexer.peekToken().type == TokenType.RParen) {
                CompileError.unexpectedToken(currentToken, "identifier or `)`");
            } else if (currentToken.type == TokenType.Comma) {
                nextToken();
            } else {
                assertToken(TokenType.RParen, "comma or closing parenthesis");
            }
        }

        final call = new Expression(nodePos, new FunctionCall(nodePos, target, callParameters));

        return if (lexer.peekToken().type == TokenType.LParen) {
            nextToken();
            parseCall(call);
        } else {
            nextToken();
            call;
        }
    }

    function parseVariable():Variable {
        final nodePos = currentToken.position;

        var mutable = currentToken.type == TokenType.Mut;

        nextToken();
        assertToken(TokenType.Ident, "identifier");

        final name = currentToken.literal;

        nextToken();
        assertToken(TokenType.Assign, "`=`");

        nextToken();

        final value = expressionParser.parseExpression();

        assertSemicolon();

        return new Variable(nodePos, name, value, mutable);
    }

    function parseReturn():Return {
        final nodePos = currentToken.position;

        nextToken();

        final returnValue = expressionParser.parseExpression();

        assertSemicolon();

        return new Return(nodePos, returnValue);
    }

    function parseBreak():Break {
        final nodePos = currentToken.position;
        nextToken();

        assertSemicolon();

        return new Break(nodePos);
    }

    public function parseIf():If {
        final nodePos = currentToken.position;

        nextToken();

        final condition = expressionParser.parseExpression();

        assertToken(TokenType.LBrace, "`{`");

        final consequence = parseBlock();
        var alternative:Block = null;

        if (lexer.peekToken().type == TokenType.Else) {
            nextToken();
            nextToken();

            assertToken(TokenType.LBrace, "`{`");
            
            alternative = parseBlock();
        }

        return new If(nodePos, condition, consequence, alternative);
    }

    function parseWhile():While {
        final nodePos = currentToken.position;

        nextToken();

        final condition = expressionParser.parseExpression();

        assertToken(TokenType.LBrace, "`{`");

        final block = parseBlock();

        return new While(nodePos, condition, block);
    }

    function parseVariableAssign() {
        final nodePos = currentToken.position;
        final name = currentToken.literal;

        nextToken();
        assertToken(TokenType.Assign, "`=`");

        nextToken();

        final value = expressionParser.parseExpression();

        assertSemicolon();

        return new VariableAssign(nodePos, name, value);
    }

    function assertToken(type:TokenType, expected:String) {
        if (currentToken.type != type) {
            CompileError.unexpectedToken(currentToken, expected);
        }
    }

    function assertSemicolon() {
        if (currentToken.type != TokenType.Semicolon) {
            CompileError.missingSemicolon(currentToken);
        }
    }

    function parseToken(block:Block) {
        switch (currentToken.type) {
            case TokenType.Let | TokenType.Mut: block.addNode(parseVariable());
            case TokenType.Return: block.addNode(parseReturn());
            case TokenType.If: block.addNode(parseIf());
            case TokenType.While: block.addNode(parseWhile());
            case TokenType.Break: block.addNode(parseBreak());
            case TokenType.LBrace: block.addNode(parseBlock());
            case TokenType.Ident:
                if (lexer.peekToken().type == TokenType.Assign) {
                    block.addNode(parseVariableAssign());
                } else {
                    final nodePos = currentToken.position;
                    final expression = expressionParser.parseExpression();
                    block.addNode(new Statement(nodePos, expression));
                    assertSemicolon();
                }
            case TokenType.Illegal: CompileError.illegalToken(currentToken);
            default:
                final nodePos = currentToken.position;
                final expression = expressionParser.parseExpression();
                block.addNode(new Statement(nodePos, expression));
                assertSemicolon();
        }
    }
}