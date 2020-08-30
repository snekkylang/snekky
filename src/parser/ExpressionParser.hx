package parser;

import error.CompileError;
import parser.nodes.Boolean;
import parser.nodes.datatypes.StringN;
import lexer.Lexer;
import parser.nodes.Node;
import parser.nodes.operators.*;
import parser.nodes.Ident;
import lexer.TokenType;
import parser.nodes.Expression;

class ExpressionParser {

    final parser:Parser;
    final lexer:Lexer;

    public function new(parser:Parser, lexer:Lexer) {
        this.parser = parser;
        this.lexer = lexer;
    }

    public function parseExpression():Expression {
        return new Expression(parser.currentToken.position, disjunction());
    }

    function disjunction():Node {
        var left = conjunction();

        while (parser.currentToken.type == TokenType.LogicOr) {
            parser.nextToken();
            final nodePos = parser.currentToken.position;
            final right = conjunction();

            left = new LogicOr(nodePos, left, right);
        }

        return left;
    }

    function conjunction():Node {
        var left = comparison();

        while (parser.currentToken.type == TokenType.LogicAnd) {
            parser.nextToken();
            final nodePos = parser.currentToken.position;
            final right = comparison();

            left = new LogicAnd(nodePos, left, right);
        }

        return left;
    }

    function comparison():Node {
        final left = numeric();

        return switch (parser.currentToken.type) {
            case TokenType.SmallerThan:
                parser.nextToken();
                final nodePos = parser.currentToken.position;
                final right = numeric();
                new SmallerThan(nodePos, left, right);
            case TokenType.GreaterThan:
                parser.nextToken();
                final nodePos = parser.currentToken.position;
                final right = numeric();
                new GreaterThan(nodePos, left, right);
            case TokenType.Equal:
                parser.nextToken();
                final nodePos = parser.currentToken.position;
                final right = numeric();
                new Equal(nodePos, left, right);
            default: left;
        }
    }

    function numeric():Node {
        var left = term();

        while (true) {
            left = switch(parser.currentToken.type) {
                case TokenType.Plus:
                    parser.nextToken();
                    final nodePos = parser.currentToken.position;
                    final right = term();
                    new Plus(nodePos, left, right);
                case TokenType.Minus:
                    parser.nextToken();
                    final nodePos = parser.currentToken.position;
                    final right = term();
                    new Minus(nodePos, left, right);
                default: break;
            }
        }

        return left;
    }

    function term():Node {
        var left = signedFactor();

        while (true) {
            left = switch(parser.currentToken.type) {
                case TokenType.Multiply:
                    parser.nextToken();
                    final nodePos = parser.currentToken.position;
                    final right = term();
                    new Multiply(nodePos, left, right);
                case TokenType.Divide:
                    parser.nextToken();
                    final nodePos = parser.currentToken.position;
                    final right = term();
                    new Divide(nodePos, left, right);
                case TokenType.Modulo:
                    parser.nextToken();
                    final nodePos = parser.currentToken.position;
                    final right = term();
                    new Modulo(nodePos, left, right);
                default: break;
            }
        }

        return left;
    }

    function signedFactor():Node {
        final minus = parser.currentToken.type == TokenType.Minus;

        if (minus) {
            parser.nextToken();
        }

        final right = factor();

        return if (minus) {
            new Negation(parser.currentToken.position, right);
        } else right;
    }

    function factor():Node {
        return switch (parser.currentToken.type) {
            case TokenType.LParen:
                parser.nextToken();
                final disjunction = disjunction();

                if (parser.currentToken.type != TokenType.RParen) {
                    CompileError.unexpectedToken(parser.currentToken, "`)`");
                }

                parser.nextToken();

                disjunction;

            case TokenType.Ident:
                final ident = new Ident(parser.currentToken.position, parser.currentToken.literal);
                parser.nextToken();

                if (parser.currentToken.type == TokenType.LParen) {
                    parser.parseCall(new Expression(parser.currentToken.position, ident)).value;
                } else {
                    ident; 
                }

            case TokenType.Number:
                final number = parser.parseNumber();
                parser.nextToken();
                
                number;

            case TokenType.String:
                final string = new StringN(parser.currentToken.position, parser.currentToken.literal);
                parser.nextToken();

                string;

            case TokenType.Function:
                parser.nextToken();
                parser.parseFunction();

            case TokenType.True:
                final boolean = new Boolean(parser.currentToken.position, true);
                parser.nextToken();

                boolean;

            case TokenType.False:
                final boolean = new Boolean(parser.currentToken.position, false);
                parser.nextToken();

                boolean;

            default: 
                CompileError.unexpectedToken(parser.currentToken, "expression");
                new Node(-1, NodeType.Ident);
        }
    }
}
