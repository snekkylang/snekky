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

    public function parseNumber():Node { // TODO: error check
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

        if (currentToken.type != TokenType.LParen) {
            CompileError.unexpectedToken(currentToken, "`(`");
        }

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
            } else if (currentToken.type != TokenType.Comma) {
                CompileError.unexpectedToken(currentToken, "identifier");
            }

            nextToken();
        }

        nextToken();

        if (currentToken.type != TokenType.LBrace) {
            CompileError.unexpectedToken(currentToken, "`{`");
        }

        final block = parseBlock();

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
            } else if (currentToken.type != TokenType.RParen) {
                CompileError.unexpectedToken(currentToken, "comma or closing parenthesis");
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
        if (currentToken.type != TokenType.Ident) {
            CompileError.unexpectedToken(currentToken, "identifier");
        }

        final name = currentToken.literal;

        nextToken();
        if (currentToken.type != TokenType.Assign) {
            CompileError.unexpectedToken(currentToken, "`=`");
        }

        nextToken();

        final value = expressionParser.parseExpression();

        return new Variable(nodePos, name, value, mutable);
    }

    function parseReturn():Return {
        final nodePos = currentToken.position;

        nextToken();

        final returnValue = expressionParser.parseExpression();

        return new Return(nodePos, returnValue);
    }

    function parseBreak():Break {
        final nodePos = currentToken.position;
        nextToken();

        return new Break(nodePos);
    }

    function parseIf():If {
        final nodePos = currentToken.position;

        nextToken();

        final condition = expressionParser.parseExpression();

        if (currentToken.type != TokenType.LBrace) {
            CompileError.unexpectedToken(currentToken, "`{`");
        }

        final consequence = parseBlock();
        var alternative:Block = null;

        if (lexer.peekToken().type == TokenType.Else) {
            nextToken();
            nextToken();

            if (currentToken.type != TokenType.LBrace) {
                CompileError.unexpectedToken(currentToken, "`{`");
            }
            
            alternative = parseBlock();
        }

        return new If(nodePos, condition, consequence, alternative);
    }

    function parseWhile():While {
        final nodePos = currentToken.position;

        nextToken();

        final condition = expressionParser.parseExpression();

        if (currentToken.type != TokenType.LBrace) {
            CompileError.unexpectedToken(currentToken, "`{`");
        }

        final block = parseBlock();

        return new While(nodePos, condition, block);
    }

    function parseVariableAssign() {
        final nodePos = currentToken.position;
        final name = currentToken.literal;

        nextToken();
        if (currentToken.type != TokenType.Assign) {
            CompileError.unexpectedToken(currentToken, "`=`");
        }

        nextToken();

        final value = expressionParser.parseExpression();

        return new VariableAssign(nodePos, name, value);
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
                }
            case TokenType.Illegal: CompileError.illegalToken(currentToken);
            default:
                final nodePos = currentToken.position;
                final expression = expressionParser.parseExpression();
                block.addNode(new Statement(nodePos, expression));
        }
    }
}