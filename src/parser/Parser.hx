package parser;

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
    public var ast = new Block(0);
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

    private function parseExpression() {
        final output:Array<Node> = [];
        final operators:Array<Operator> = [];

        while (true) {
            if (currentToken.type == TokenType.Eof) {
                Error.unexpectedEof();
            }

            switch (currentToken.type) {
                case TokenType.Number: output.push(parseNumber());
                case TokenType.LParen: operators.push(new LParen(currentToken.line));
                case TokenType.RParen: {
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

        trace(output);
    }

    function parseVariable() {
        var mutable = currentToken.type == Mut;

        if (lexer.peekToken().type != Ident) {
            Error.unexpectedToken();
        }

        nextToken();

        final name = currentToken.literal;

        if (lexer.peekToken().type != Assign) {
            Error.unexpectedToken();
        }

        nextToken();
        nextToken();

        parseExpression();
    }

    function parseToken(block:Block) {
        switch (currentToken.type) {
            case Let:
                parseVariable();
            default: 
        }
    }
}