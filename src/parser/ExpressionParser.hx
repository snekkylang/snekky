package parser;

import ast.nodes.*;
import ast.nodes.datatypes.*;
import ast.NodeType;
import error.CompileError;
import lexer.Lexer;
import lexer.TokenType;

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

            left = new Operator(nodePos, NodeType.LogicOr, left, right);
        }

        return left;
    }

    function conjunction():Node {
        var left = comparison();

        while (parser.currentToken.type == TokenType.LogicAnd) {
            parser.nextToken();
            final nodePos = parser.currentToken.position;
            final right = comparison();

            left = new Operator(nodePos, NodeType.LogicAnd, left, right);
        }

        return left;
    }

    function comparison():Node {
        final left = numeric();

        final type = switch (parser.currentToken.type) {
            case TokenType.SmallerThan: NodeType.SmallerThan;
            case TokenType.GreaterThan: NodeType.GreaterThan;
            case TokenType.Equal: NodeType.Equal;
            default: return left;
        }

        parser.nextToken();
        final nodePos = parser.currentToken.position;
        final right = numeric();
        return new Operator(nodePos, type, left, right);
    }

    function numeric():Node {
        var left = term();

        while (true) {
            final type = switch(parser.currentToken.type) {
                case TokenType.Plus: NodeType.Plus;
                case TokenType.Minus: NodeType.Minus;
                default: break;
            }


            parser.nextToken();
            final nodePos = parser.currentToken.position;
            final right = term();
            left = new Operator(nodePos, type, left, right);
        }

        return left;
    }

    function term():Node {
        var left = signedFactor();

        while (true) {
            final type = switch(parser.currentToken.type) {
                case TokenType.Multiply: NodeType.Multiply;
                case TokenType.Divide: NodeType.Divide;
                case TokenType.Modulo: NodeType.Modulo;
                default: break;
            }

            parser.nextToken();
            final nodePos = parser.currentToken.position;
            final right = term();
            left = new Operator(nodePos, type, left, right);
        }

        return left;
    }

    function signedFactor():Node {
        return switch (parser.currentToken.type) {
            case TokenType.Minus:
                parser.nextToken();

                final right = factor();

                new Operator(parser.currentToken.position, NodeType.Negation, null, right);
            case TokenType.Bang:
                parser.nextToken();

                final right = factor();

                new Operator(parser.currentToken.position, NodeType.Inversion, null, right);
            default: factor();
        }
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
                final func = parser.parseFunction();

                if (parser.currentToken.type == TokenType.LParen) {
                    parser.parseCall(new Expression(parser.currentToken.position, func)).value;
                } else {
                    func; 
                }

            case TokenType.True:
                final boolean = new Boolean(parser.currentToken.position, true);
                parser.nextToken();

                boolean;

            case TokenType.False:
                final boolean = new Boolean(parser.currentToken.position, false);
                parser.nextToken();

                boolean;

            case TokenType.If:
                final ifN = parser.parseIf();
                parser.nextToken();

                ifN;

            default: 
                CompileError.unexpectedToken(parser.currentToken, "expression");
                new Node(-1, NodeType.Ident);
        }
    }
}
