package parser;

import error.CompileError;
import parser.nodes.datatypes.*;
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

    @:nullSafety(Off)
    public function parseNumber():Node {
        final n = Std.parseInt(currentToken.literal);

        return new IntN(currentToken.line, n);
    }

    function parseBlock():Block {
        final block = new Block(currentToken.line);

        while (currentToken.type != TokenType.RBrace) {
            if (currentToken.type == TokenType.Eof) {
                CompileError.unexpectedEof(currentToken, lexer.code);
            }

            parseToken(block);
            nextToken();
        }

        return block;
    }

    public function parseFunction():FunctionN {
        if (currentToken.type != TokenType.LParen) {
            CompileError.unexpectedToken(currentToken, lexer.code, "`(`");
        }

        nextToken();

        final parameters:Array<Ident> = [];

        while (currentToken.type != TokenType.RParen) {
            if (currentToken.type == TokenType.Ident) {
                parameters.push(new Ident(currentToken.line, currentToken.literal));
            } else if (currentToken.type != TokenType.Comma) {
                CompileError.unexpectedToken(currentToken, lexer.code, "identifier");
            }

            nextToken();
        }

        nextToken();

        if (currentToken.type != TokenType.LBrace) {
            CompileError.unexpectedToken(currentToken, lexer.code, "`{`");
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
            nextToken();
            call;
        }
    }

    function parseVariable():Variable {
        var mutable = currentToken.type == TokenType.Mut;

        nextToken();
        if (currentToken.type != TokenType.Ident) {
            CompileError.unexpectedToken(currentToken, lexer.code, "indentifier");
        }

        final name = currentToken.literal;

        nextToken();
        if (currentToken.type != TokenType.Assign) {
            CompileError.unexpectedToken(currentToken, lexer.code, "`=`");
        }

        nextToken();

        final value = expressionParser.parseExpression();

        return new Variable(currentToken.line, name, value, mutable);
    }

    function parseReturn():Return {
        nextToken();

        final returnValue = expressionParser.parseExpression();

        return new Return(currentToken.line, returnValue);
    }

    function parseBreak():Break {
        nextToken();

        return new Break(currentToken.line);
    }

    function parseIf():If {
        nextToken();

        final condition = expressionParser.parseExpression();

        if (currentToken.type != TokenType.LBrace) {
            CompileError.unexpectedToken(currentToken, lexer.code, "`{`");
        }

        nextToken();

        final consequence = parseBlock();
        var alternative:Block = null;

        if (lexer.peekToken().type == TokenType.Else) {
            nextToken();
            nextToken();

            if (currentToken.type != TokenType.LBrace) {
                CompileError.unexpectedToken(currentToken, lexer.code, "`{`");
            }

            nextToken();
            
            alternative = parseBlock();
        }

        return new If(currentToken.line, condition, consequence, alternative);
    }

    function parseWhile():While {
        nextToken();

        final condition = expressionParser.parseExpression();

        if (currentToken.type != TokenType.LBrace) {
            CompileError.unexpectedToken(currentToken, lexer.code, "`{`");
        }

        nextToken();

        final block = parseBlock();

        return new While(currentToken.line, condition, block);
    }

    function parseVariableAssign() {
        final name = currentToken.literal;

        nextToken();
        if (currentToken.type != TokenType.Assign) {
            CompileError.unexpectedToken(currentToken, lexer.code, "`=`");
        }

        nextToken();

        final value = expressionParser.parseExpression();

        return new VariableAssign(currentToken.line, name, value);
    }

    function parseToken(block:Block) {
        switch (currentToken.type) {
            case TokenType.Let | TokenType.Mut: block.addNode(parseVariable());
            case TokenType.Return: block.addNode(parseReturn());
            case TokenType.If: block.addNode(parseIf());
            case TokenType.While: block.addNode(parseWhile());
            case TokenType.Break: block.addNode(parseBreak());
            case TokenType.Ident:
                if (lexer.peekToken().type == TokenType.Assign) {
                    block.addNode(parseVariableAssign());
                } else {
                    final expression = expressionParser.parseExpression();
                    block.addNode(new Statement(currentToken.line, expression));   
                }
            case TokenType.Illegal: CompileError.illegalToken(currentToken, lexer.code);
            default:
                final expression = expressionParser.parseExpression();
                block.addNode(new Statement(currentToken.line, expression));
        }
    }
}