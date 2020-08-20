package parser;

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