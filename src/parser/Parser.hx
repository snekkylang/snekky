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
    public var ast = new BlockNode(1);
    public var currentToken:Token;
    
    public function new(lexer:Lexer) {
        this.lexer = lexer;

        expressionParser = new ExpressionParser(this, lexer);
        currentToken = lexer.readToken();
    }

    public function generateAst() {
        while (currentToken.type != TokenType.Eof) {
            parseToken(ast);
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
        nextToken();
        return new FloatNode(nodePos, n);
    }

    function parseBlock():BlockNode {
        nextToken();
        
        final block = new BlockNode(currentToken.position);

        while (currentToken.type != TokenType.RBrace) {
            if (currentToken.type == TokenType.Eof) {
                CompileError.unexpectedEof(currentToken);
            }

            parseToken(block);
        }

        return block;
    }

    public function parseFunction():FunctionNode {
        final nodePos = currentToken.position;

        assertToken(TokenType.LParen, "`(`");

        nextToken();

        final parameters:Array<IdentNode> = [];

        while (currentToken.type != TokenType.RParen) {
            if (currentToken.type == TokenType.Ident) {
                parameters.push(new IdentNode(currentToken.position, currentToken.literal));
                if (lexer.peekToken().type != TokenType.Comma && lexer.peekToken().type != TokenType.RParen) {
                    CompileError.unexpectedToken(currentToken, "`,` or `)`");
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

        return new FunctionNode(nodePos, block, parameters);
    }

    public function parseCall(target:ExpressionNode):ExpressionNode {
        final nodePos = currentToken.position;

        nextToken();

        final callParameters:Array<ExpressionNode> = [];

        while (currentToken.type != TokenType.RParen) {
            callParameters.push(expressionParser.parseExpression());
            if (currentToken.type == TokenType.Comma && lexer.peekToken().type == TokenType.RParen) {
                CompileError.unexpectedToken(currentToken, "identifier or `)`");
            } else if (currentToken.type == TokenType.Comma) {
                nextToken();
            } else {
                assertToken(TokenType.RParen, "`,` or `)`");
            }
        }

        nextToken();

        return new ExpressionNode(nodePos, new CallNode(nodePos, target, callParameters));
    }

    public function parseIndex(target:ExpressionNode):ExpressionNode {
        final nodePos = currentToken.position;

        final index = switch (currentToken.type) {
            case TokenType.Dot:
                nextToken();
                assertToken(TokenType.Ident, "identifier");

                final eIndex = new ExpressionNode(currentToken.position, new StringNode(currentToken.position, currentToken.literal));
                nextToken();

                eIndex;
            case TokenType.LBracket:
                nextToken();

                final eIndex = expressionParser.parseExpression();

                assertToken(TokenType.RBracket, "`]`");
                nextToken();
    
                eIndex;
            default: 
                CompileError.unexpectedToken(currentToken, "`[` or `.`");
                null;
        }
        
        final indexNode = new ExpressionNode(nodePos, new IndexNode(nodePos, target, index));

        return if (currentToken.type == TokenType.Assign) {
            nextToken();
            final value = expressionParser.parseExpression();

            new ExpressionNode(nodePos, new IndexAssignNode(nodePos, indexNode, value));
        } else {
            indexNode;
        }
    }

    public function parseArray():ArrayNode {
        final nodePos = currentToken.position;

        nextToken();

        final values:Array<ExpressionNode> = [];

        while (currentToken.type != TokenType.RBracket) {
            values.push(expressionParser.parseExpression());
            if (currentToken.type == TokenType.Comma && lexer.peekToken().type == TokenType.RBracket) {
                CompileError.unexpectedToken(currentToken, "expression or `]`");
            } else if (currentToken.type == TokenType.Comma) {
                nextToken();
            } else {
                assertToken(TokenType.RBracket, "`,` or `]`");
            }
        }

        nextToken();

        return new ArrayNode(nodePos, values);  
    }

    public function parseHash():HashNode {
        final nodePos = currentToken.position;

        nextToken();

        final values:Map<ExpressionNode, ExpressionNode> = new Map();

        while (currentToken.type != TokenType.RBrace) {
            final key = expressionParser.parseExpression();
            assertToken(TokenType.Colon, "`:`");
            nextToken();
            
            final value = expressionParser.parseExpression();
            if (currentToken.type != TokenType.Comma && currentToken.type != TokenType.RBrace) {
                CompileError.unexpectedToken(currentToken, "`,` or `}`");
            } else if (currentToken.type == TokenType.Comma) {
                nextToken();
            }

            values.set(key, value);
        }

        nextToken();

        return new HashNode(nodePos, values);
    }

    function parseVariable():VariableNode {
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
        nextToken();

        return new VariableNode(nodePos, name, value, mutable);
    }

    function parseReturn():ReturnNode {
        final nodePos = currentToken.position;

        nextToken();

        final returnValue = if (currentToken.type != TokenType.Semicolon) {
            expressionParser.parseExpression();
        } else {
            null;
        }

        assertSemicolon();
        nextToken();

        return new ReturnNode(nodePos, returnValue);
    }

    function parseBreak():BreakNode {
        final nodePos = currentToken.position;
        nextToken();

        assertSemicolon();
        nextToken();

        return new BreakNode(nodePos);
    }

    public function parseIf():IfNode {
        final nodePos = currentToken.position;

        nextToken();

        final condition = expressionParser.parseExpression();

        assertToken(TokenType.LBrace, "`{`");

        final consequence = parseBlock();
        var alternative:BlockNode = null;

        if (lexer.peekToken().type == TokenType.Else) {
            nextToken();
            nextToken();

            assertToken(TokenType.LBrace, "`{`");
            
            alternative = parseBlock();
        }

        nextToken();

        return new IfNode(nodePos, condition, consequence, alternative);
    }

    function parseWhile():WhileNode {
        final nodePos = currentToken.position;

        nextToken();

        final condition = expressionParser.parseExpression();

        assertToken(TokenType.LBrace, "`{`");

        final block = parseBlock();

        nextToken();

        return new WhileNode(nodePos, condition, block);
    }

    function parseVariableAssign():VariableAssignNode {
        final nodePos = currentToken.position;
        final name = currentToken.literal;

        nextToken();
        assertToken(TokenType.Assign, "`=`");

        nextToken();

        final value = expressionParser.parseExpression();

        assertSemicolon();
        nextToken();

        return new VariableAssignNode(nodePos, name, value);
    }

    function parseStatement():Node {
        final nodePos = currentToken.position;
        final expression = expressionParser.parseExpression();
        final statement = if (currentToken.type == TokenType.RBrace) {
            expression;
        } else {
            assertSemicolon();
            nextToken();    
            new StatementNode(nodePos, expression);
        }

        return statement;
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

    function parseToken(block:BlockNode) {
        switch (currentToken.type) {
            case TokenType.Let | TokenType.Mut: block.addNode(parseVariable());
            case TokenType.Return: block.addNode(parseReturn());
            case TokenType.If: block.addNode(parseIf());
            case TokenType.While: block.addNode(parseWhile());
            case TokenType.Break: block.addNode(parseBreak());
            case TokenType.LBrace: 
                block.addNode(parseBlock()); 
                nextToken();
            case TokenType.Ident:
                if (lexer.peekToken().type == TokenType.Assign) {
                    block.addNode(parseVariableAssign());
                } else {
                    block.addNode(parseStatement());
                }
            case TokenType.Illegal: CompileError.illegalToken(currentToken);
            default: block.addNode(parseStatement());
        }
    }
}