package parser;

import ast.nodes.*;
import ast.nodes.datatypes.*;
import ast.NodeType;
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

        while (parser.currentToken.type == TokenType.Or) {
            parser.nextToken();
            final nodePos = parser.currentToken.position;
            final right = conjunction();

            left = new OperatorNode(nodePos, NodeType.Or, left, right);
        }

        return left;
    }

    function conjunction():Node {
        var left = bitOr();

        while (parser.currentToken.type == TokenType.And) {
            parser.nextToken();
            final nodePos = parser.currentToken.position;
            final right = comparison();

            left = new OperatorNode(nodePos, NodeType.And, left, right);
        }

        return left;
    }

    function bitOr():Node {
        var left = bitXor();

        while (true) {
            final type = switch(parser.currentToken.type) {
                case TokenType.BitOr: NodeType.BitOr;
                default: break;
            }

            parser.nextToken();
            final nodePos = parser.currentToken.position;
            final right = term();
            left = new OperatorNode(nodePos, type, left, right);
        }

        return left;
    }

    
    function bitXor():Node {
        var left = bitAnd();

        while (true) {
            final type = switch(parser.currentToken.type) {
                case TokenType.BitXor: NodeType.BitXor;
                default: break;
            }

            parser.nextToken();
            final nodePos = parser.currentToken.position;
            final right = term();
            left = new OperatorNode(nodePos, type, left, right);
        }

        return left;
    }

    function bitAnd():Node {
        var left = comparison();

        while (true) {
            final type = switch(parser.currentToken.type) {
                case TokenType.BitAnd: NodeType.BitAnd;
                default: break;
            }

            parser.nextToken();
            final nodePos = parser.currentToken.position;
            final right = term();
            left = new OperatorNode(nodePos, type, left, right);
        }

        return left;
    }

    function comparison():Node {
        final left = range();

        final type = switch (parser.currentToken.type) {
            case TokenType.LessThan: NodeType.LessThan;
            case TokenType.GreaterThan: NodeType.GreaterThan;
            case TokenType.LessThanOrEqual: NodeType.LessThanOrEqual;
            case TokenType.GreaterThanOrEqual: NodeType.GreaterThanOrEqual;
            case TokenType.Equals: NodeType.Equals;
            case TokenType.NotEquals: NodeType.NotEquals;
            default: return left;
        }

        parser.nextToken();
        final nodePos = parser.currentToken.position;
        final right = range();
        return new OperatorNode(nodePos, type, left, right);
    }

    function range():Node {
        var start = new ExpressionNode(parser.currentToken.position, bitShift());

        while (true) {
            final inclusive = switch(parser.currentToken.type) {
                case TokenType.InclusiveRange: true;
                case TokenType.ExclusiveRange: false;
                default: break;
            }

            parser.nextToken();
            final nodePos = parser.currentToken.position;
            final end = new ExpressionNode(nodePos, numeric());
            start = new ExpressionNode(nodePos, new RangeNode(nodePos, start, end, inclusive));
        }

        return start;
    }

    function bitShift():Node {
        var left = numeric();

        while (true) {
            final type = switch(parser.currentToken.type) {
                case TokenType.BitShiftLeft: NodeType.BitShiftLeft;
                case TokenType.BitShiftRight: NodeType.BitShiftRight;
                default: break;
            }

            parser.nextToken();
            final nodePos = parser.currentToken.position;
            final right = term();
            left = new OperatorNode(nodePos, type, left, right);
        }

        return left; 
    }

    function numeric():Node {
        var left = term();

        while (true) {
            final type = switch(parser.currentToken.type) {
                case TokenType.Plus: NodeType.Add;
                case TokenType.Minus: NodeType.Subtract;
                case TokenType.ConcatString: NodeType.ConcatString;
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
        var left = signedFactor();

        while (true) {
            final type = switch(parser.currentToken.type) {
                case TokenType.Asterisk: NodeType.Multiply;
                case TokenType.Slash: NodeType.Divide;
                case TokenType.Percent: NodeType.Modulo;
                default: break;
            }

            parser.nextToken();
            final nodePos = parser.currentToken.position;
            final right = term();
            left = new OperatorNode(nodePos, type, left, right);
        }

        return left;
    }

    function signedFactor():Node {
        return switch (parser.currentToken.type) {
            case TokenType.Minus:
                parser.nextToken();

                final right = access();

                new OperatorNode(parser.currentToken.position, NodeType.Negate, null, right);
            case TokenType.Bang:
                parser.nextToken();

                final right = access();

                new OperatorNode(parser.currentToken.position, NodeType.Not, null, right);
            case TokenType.BitNot:
                parser.nextToken();

                final right = access();

                new OperatorNode(parser.currentToken.position, NodeType.BitNot, null, right);
            default: access();
        }
    }

    function access():Node {
        var left = new ExpressionNode(parser.currentToken.position, factor());

        while (true) {
            left = switch (parser.currentToken.type) {
                case LParen: parser.parseCall(left);
                case LBracket: parser.parseIndex(left);
                case Dot: parser.parseIndex(left);

                default: break;
            }
        }

        return left;
    }

    function factor():Node {
        return switch (parser.currentToken.type) {
            case TokenType.LParen:
                parser.nextToken();
                final disjunction = disjunction();

                if (parser.currentToken.type != TokenType.RParen) {
                    parser.error.unexpectedToken(parser.currentToken, "`)`");
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
                parser.parseIf();
            case TokenType.When:
                parser.parseWhen();
            case TokenType.LBracket:
                parser.parseArray();
            case TokenType.LBrace:
                if (parser.resolveHashBlockAmbiguity() == NodeType.Block) {
                    final block = parser.parseBlock();
                    parser.nextToken();

                    block;
                } else {
                    parser.parseHash();
                }
            case TokenType.Null:
                final nullN = new NullNode(parser.currentToken.position);
                parser.nextToken();

                nullN;
            case TokenType.Regex:
                parser.parseRegex();
            default: 
                parser.error.unexpectedToken(parser.currentToken, "expression");
                null;
        }
    }
}
