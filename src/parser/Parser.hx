package parser;

import sys.io.File;
import haxe.format.JsonPrinter;
import parser.nodes.operators.LParen;
import parser.nodes.operators.Multiply;
import parser.nodes.operators.Divide;
import parser.nodes.operators.Minus;
import parser.nodes.operators.Plus;
import parser.nodes.datatypes.Int.IntN;
import parser.nodes.operators.Operator;
import lexer.TokenType;
import lexer.Token;
import lexer.Lexer;
import parser.nodes.*;

class Parser {

    final lexer:Lexer;
    public var ast = new Block(1);
    var currentToken:Token;
    
    public function new(lexer:Lexer) {
        this.lexer = lexer;
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

    function nextToken() {
        currentToken = lexer.readToken();
    }

    private function getOperatorPrecedence(op:Node) {
        return switch (op.type) {
            case NodeType.Plus | NodeType.Minus: 4;
            case NodeType.Multiply | NodeType.Divide: 3;
            default: 0;
        }
    }

    @:nullSafety(Off)
    private function parseNumber() {
        final n = Std.parseInt(currentToken.literal);

        return new IntN(currentToken.line, n);
    }

    function parseCallParameters() {
        final parameters:Array<Expression> = [];

        if (lexer.peekToken().type == TokenType.RParen) {
            nextToken();
            return parameters;
        }

        while (currentToken.type != TokenType.RParen) {
            if (currentToken.type == TokenType.Eof) {
                Error.unexpectedEof();
            }

            nextToken();
            parameters.push(parseExpression());
        }

        return parameters;
    }

    private function parseExpression(): Expression {
        final output:Array<Node> = [];
        final operators:Array<Operator> = [];

        var openBraces = 0;

        while (true) {
            if (currentToken.type == TokenType.Eof) {
                Error.unexpectedEof();
            }

            switch (currentToken.type) {
                case TokenType.Number: output.push(parseNumber());
                case TokenType.Ident: {
                    if (lexer.peekToken().type == TokenType.LParen) {
                        var lastTarget: Expression = new Expression(currentToken.line, [new Ident(currentToken.line, currentToken.literal)]);

                        do {
                            nextToken();

                            lastTarget = new Expression(currentToken.line, [new FunctionCall(currentToken.line, lastTarget, parseCallParameters())]);
                        } while (lexer.peekToken().type == TokenType.LParen);

                        output.push(lastTarget.value[0]); // todo: is this necessary?
                    } else {
                        output.push(new Ident(currentToken.line, currentToken.literal));
                    }
                }
                case TokenType.LParen: {
                    operators.push(new LParen(currentToken.line));
                    openBraces++;
                }
                case TokenType.RParen: {
                    openBraces--;

                    if (openBraces < 0) {
                        break;
                    }

                    while (operators.length > 0 && operators[operators.length - 1].type != NodeType.LParen) {
                        output.push(operators.pop());
                    }

                    if (operators.length > 0 && operators[operators.length - 1].type == NodeType.LParen) {
                        operators.pop();
                    }
                }
                default: {
                    final op = switch (currentToken.type) {
                        case TokenType.Plus: new Plus(currentToken.line);
                        case TokenType.Minus: new Minus(currentToken.line);
                        case TokenType.Divide: new Divide(currentToken.line);
                        case TokenType.Multiply: new Multiply(currentToken.line);
                        default: break;
                    }
    
                    while (operators.length != 0 && (operators[operators.length - 1].precedence < op.precedence 
                        || (operators[operators.length - 1].precedence == op.precedence && operators[operators.length - 1].associativity == OperatorAssociativity.Left))
                        && operators[operators.length - 1].type != NodeType.LParen) {

                        output.push(operators.pop());
                    }
    
                    operators.push(op);
                }
            }

            nextToken();
        }

        while (operators.length != 0) {
            output.push(operators.pop());
        }

        return new Expression(currentToken.line, output);
    }

    function parseVariable() {
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

        final value = parseExpression();

        return new Variable(currentToken.line, name, value, mutable);
    }

    function parseIdent() { // TODO: Parse assigns
        parseExpression();
    }

    function parseToken(block:Block) {
        switch (currentToken.type) {
            case TokenType.Let | TokenType.Mut: block.addNode(parseVariable());
            case TokenType.Ident | TokenType.Number: block.addNode(parseExpression());
            default: 
        }
    }
}