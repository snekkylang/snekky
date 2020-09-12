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

    public function parseExpression():ExpressionNode {
        return new ExpressionNode(parser.currentToken.position, disjunction());
    }

    function disjunction():Node {
        var left = conjunction();

        while (parser.currentToken.type == TokenType.LogicOr) {
            parser.nextToken();
            final nodePos = parser.currentToken.position;
            final right = conjunction();

            left = new OperatorNode(nodePos, NodeType.LogicOr, left, right);
        }

        return left;
    }

    function conjunction():Node {
        var left = comparison();

        while (parser.currentToken.type == TokenType.LogicAnd) {
            parser.nextToken();
            final nodePos = parser.currentToken.position;
            final right = comparison();

            left = new OperatorNode(nodePos, NodeType.LogicAnd, left, right);
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
        return new OperatorNode(nodePos, type, left, right);
    }

    function numeric():Node {
        var left = term();

        while (true) {
            final type = switch(parser.currentToken.type) {
                case TokenType.Plus: NodeType.Plus;
                case TokenType.Minus: NodeType.Minus;
                case TokenType.Dot: NodeType.StringConc;
                default: break;
            }


            parser.nextToken();
            final nodePos = parser.currentToken.position;
            final right = term();
            left = new OperatorNode(nodePos, type, left, right);
        }

        return left;
    }

    function term():Node {
        var left = access();

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
            left = new OperatorNode(nodePos, type, left, right);
        }

        return left;
    }

    function access():Node {
        var left = new ExpressionNode(parser.currentToken.position, signedFactor());

        while (true) {
            switch (parser.currentToken.type) {
                case LParen: left = parser.parseCall(left);
                case LBracket: left = parser.parseIndex(left);

                default: break;
            }
        }

        return left;
    }

    function signedFactor():Node {
        return switch (parser.currentToken.type) {
            case TokenType.Minus:
                parser.nextToken();

                final right = factor();

                new OperatorNode(parser.currentToken.position, NodeType.Negation, null, right);
            case TokenType.Bang:
                parser.nextToken();

                final right = factor();

                new OperatorNode(parser.currentToken.position, NodeType.Inversion, null, right);
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
                final ident = new IdentNode(parser.currentToken.position, parser.currentToken.literal);
                parser.nextToken();

                ident; 

            case TokenType.Number:
                parser.parseNumber();

            case TokenType.String:
                final string = new StringNode(parser.currentToken.position, parser.currentToken.literal);
                parser.nextToken();

                string;

            case TokenType.Function:
                parser.nextToken();
                parser.parseFunction();

            case TokenType.True:
                final boolean = new BooleanNode(parser.currentToken.position, true);
                parser.nextToken();

                boolean;

            case TokenType.False:
                final boolean = new BooleanNode(parser.currentToken.position, false);
                parser.nextToken();

                boolean;

            case TokenType.If:
                final ifN = parser.parseIf();

                ifN;

            case TokenType.LBracket:
                parser.parseArray();

            case TokenType.LBrace:
                parser.parseHash();

            case TokenType.Null:
                final nullN = new NullNode(parser.currentToken.position);
                parser.nextToken();

                nullN;

            default: 
                CompileError.unexpectedToken(parser.currentToken, "expression");
                new Node(-1, NodeType.Ident);
        }
    }
}
