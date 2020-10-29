package parser;

import ast.NodeType;
import error.CompileError;
import ast.nodes.datatypes.*;
import haxe.format.JsonPrinter;
import lexer.TokenType;
import lexer.Token;
import lexer.Lexer;
import ast.nodes.*;

class Parser {

    final lexer:Lexer;
    final expressionParser:ExpressionParser;

    public final error:CompileError;
    public final ast:FileNode;
    public var currentToken(default, null):Token;

    public function new(lexer:Lexer) {
        this.lexer = lexer;
        ast = new FileNode(1, lexer.filename, lexer.code);
        error = new CompileError(lexer.filename, lexer.code);

        expressionParser = new ExpressionParser(this, lexer);
        currentToken = lexer.readToken();
    }

    public function generateAst() {
        while (currentToken.type != TokenType.Eof) {
            parseToken(ast);
        }
    }

    public function writeAst() {
        #if target.sys
        sys.io.File.saveContent("ast.json", JsonPrinter.print(ast));
        #end
    }

    public function nextToken() {
        currentToken = lexer.readToken();
    }

    public function resolveHashBlockAmbiguity():NodeType {
        return switch [for (t in lexer.peekTokenN(2)) t.type] {
            case [TokenType.String | TokenType.Ident, TokenType.Colon]: NodeType.Hash;
            case [TokenType.RBrace, _]: NodeType.Hash;
            default: NodeType.Block;
        }
    }

    public function parseNumber():Node {
        final nodePos = currentToken.position;
        final n = Std.parseFloat(currentToken.literal);
        nextToken();
        return new FloatNode(nodePos, n);
    }

    public function parseRegex():RegexNode {
        final nodePos = currentToken.position;

        final pattern = new ExpressionNode(nodePos, new StringNode(nodePos, currentToken.literal));
        nextToken();
        final flags = if (currentToken.type == TokenType.Ident) {
            final flags = new ExpressionNode(nodePos, new StringNode(nodePos, currentToken.literal));
            nextToken();
            flags;
        } else new ExpressionNode(nodePos, new StringNode(nodePos, ""));

        return new RegexNode(nodePos, pattern, flags);
    }

    public function parseBlock():BlockNode {
        nextToken();

        final block = new BlockNode(currentToken.position);

        while (currentToken.type != TokenType.RBrace) {
            if (currentToken.type == TokenType.Eof) {
                error.unexpectedEof(currentToken);
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
                    error.unexpectedToken(currentToken, "`,` or `)`");
                }
            } else if (currentToken.type == TokenType.Comma && lexer.peekToken().type == TokenType.RParen) {
                error.unexpectedToken(currentToken, "identifier or `)`");
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
                error.unexpectedToken(currentToken, "identifier or `)`");
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
                error.unexpectedToken(currentToken, "`[` or `.`");
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
                error.unexpectedToken(currentToken, "expression or `]`");
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
            final key = if (currentToken.type == TokenType.Ident || currentToken.type == TokenType.String) {
                final eKey = new ExpressionNode(currentToken.position, new StringNode(currentToken.position, currentToken.literal));
                nextToken();

                eKey;
            } else {
                error.unexpectedToken(currentToken, "identifier or string");
                null;
            }

            assertToken(TokenType.Colon, "`:`");
            nextToken();

            final value = expressionParser.parseExpression();
            if (currentToken.type != TokenType.Comma && currentToken.type != TokenType.RBrace) {
                error.unexpectedToken(currentToken, "`,` or `}`");
            } else if (currentToken.type == TokenType.Comma) {
                nextToken();
            }

            values.set(key, value);
        }

        nextToken();

        return new HashNode(nodePos, values);
    }

    function parseVariableName():Node {
        final nodePos = currentToken.position;

        return switch (currentToken.type) {
            case TokenType.Ident: new IdentNode(nodePos, currentToken.literal);
            case TokenType.LBracket | TokenType.LBrace:
                final names:Array<String> = [];

                nextToken();
                while (currentToken.type != TokenType.RBracket && currentToken.type != TokenType.RBrace) {
                    names.push(currentToken.literal);
                    nextToken();
                    if (currentToken.type != TokenType.Comma
                        && currentToken.type != TokenType.RBracket
                        && currentToken.type != TokenType.RBrace) {
                        error.unexpectedToken(currentToken, "`,`");
                    }
                    if (currentToken.type == TokenType.Comma) {
                        nextToken();
                    }
                }

                if (currentToken.type == TokenType.RBracket) {
                    new DestructureArrayNode(nodePos, names);
                } else {
                    new DestructureHashNode(nodePos, names);
                }
            default:
                error.unexpectedToken(currentToken, "identifier or `{`");
                null;
        }
    }

    function parseVariable():VariableNode {
        final nodePos = currentToken.position;

        final mutable = currentToken.type == TokenType.Mut;

        nextToken();
        final name = parseVariableName();

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
        var alternative:Node = null;

        if (lexer.peekToken().type == TokenType.Else) {
            nextToken();
            nextToken();

            alternative = if (currentToken.type == TokenType.If) {
                parseIf();
            } else {
                assertToken(TokenType.LBrace, "`{`");

                final block = parseBlock();
                nextToken();

                block;
            }
        } else {
            nextToken();
        }

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

    public function parseWhen():WhenNode {
        final nodePos = currentToken.position;

        nextToken();

        final condition = expressionParser.parseExpression();

        assertToken(TokenType.LBrace, "`{`");

        nextToken();

        var elseCase:Node = null;
        final cases:Array<WhenNode.Case> = [];
        while (currentToken.type != TokenType.RBrace) {
            if (currentToken.type == TokenType.Else) {
                nextToken();
                assertToken(TokenType.Arrow, "`=>`");
                nextToken();
                final consequence = expressionParser.parseExpression();

                assertToken(TokenType.RBrace, "`else` entry must be the last in when-expression");

                elseCase = consequence;
            } else {
                final condition = expressionParser.parseExpression();
                assertToken(TokenType.Arrow, "`=>`");
                nextToken();
                final consequence = expressionParser.parseExpression();

                cases.push({condition: condition, consequence: consequence});
            }
        }

        nextToken();

        return new WhenNode(nodePos, condition, cases, elseCase);
    }

    function parseFor():ForNode {
        final nodePos = currentToken.position;

        nextToken();

        final variable = if (currentToken.type == TokenType.Let || currentToken.type == TokenType.Mut) {
            final mutable = currentToken.type == TokenType.Mut;
            nextToken();
            final variableName = parseVariableName();

            nextToken();
            assertToken(TokenType.In, "`in`");
            nextToken();

            new VariableNode(nodePos, variableName, null, mutable);
        } else {
            null;
        }

        final iterator = expressionParser.parseExpression();
        assertToken(TokenType.LBrace, "`{`");

        final block = parseBlock();

        nextToken();

        return new ForNode(nodePos, variable, iterator, block);
    }

    function parseVariableAssign():VariableAssignNode {
        final nodePos = currentToken.position;
        final name = new IdentNode(nodePos, currentToken.literal);

        nextToken();
        assertToken(TokenType.Assign, "`=`");

        nextToken();

        final value = expressionParser.parseExpression();

        assertSemicolon();
        nextToken();

        return new VariableAssignNode(nodePos, name, value);
    }

    public function parseVariableAssignOp():VariableAssignOpNode {
        final nodePos = currentToken.position;
        final name = new IdentNode(nodePos, currentToken.literal);

        nextToken();
        final op = currentToken;

        nextToken();

        final value = expressionParser.parseExpression();

        assertSemicolon();
        nextToken();

        return new VariableAssignOpNode(nodePos, name, switch (op.type) {
            case TokenType.PlusAssign: new OperatorNode(nodePos, NodeType.Add, name, value);
            case TokenType.MinusAssign: new OperatorNode(nodePos, NodeType.Subtract, name, value);
            case TokenType.AsteriskAssign: new OperatorNode(nodePos, NodeType.Multiply, name, value);
            case TokenType.SlashAssign: new OperatorNode(nodePos, NodeType.Divide, name, value);
            case TokenType.PercentAssign: new OperatorNode(nodePos, NodeType.Modulo, name, value);
            default:
                error.unexpectedToken(op, "operator assign");
                null;
        });
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

    function parseImport():FileNode {
        nextToken();

        assertToken(TokenType.String, "string containing path to source file");
        final filename = '${currentToken.literal}.snek';
        nextToken();
        assertSemicolon();
        nextToken();
        #if target.sys
        final code = sys.io.File.getContent(filename);
        #else
        final code = "";
        throw "Imports not supported on this target";
        #end

        final lexer = new Lexer(filename, code);

        final parser = new Parser(lexer);
        parser.generateAst();

        return parser.ast;
    }

    function assertToken(type:TokenType, expected:String) {
        if (currentToken.type != type) {
            error.unexpectedToken(currentToken, expected);
        }
    }

    function assertSemicolon() {
        if (currentToken.type != TokenType.Semicolon) {
            error.missingSemicolon(currentToken);
        }
    }

    function parseToken(block:BlockNode) {
        switch (currentToken.type) {
            case TokenType.Let | TokenType.Mut:
                block.addNode(parseVariable());
            case TokenType.Return:
                block.addNode(parseReturn());
            case TokenType.If:
                block.addNode(parseIf());
            case TokenType.While:
                block.addNode(parseWhile());
            case TokenType.For:
                block.addNode(parseFor());
            case TokenType.When:
                block.addNode(parseWhen());
            case TokenType.Break:
                block.addNode(parseBreak());
            #if target.sys
            case TokenType.Import:
                block.addNode(parseImport());
            #end
            case TokenType.LBrace:
                if (resolveHashBlockAmbiguity() == NodeType.Block) {
                    block.addNode(parseBlock());
                    nextToken();
                } else {
                    block.addNode(parseStatement());
                }
            case TokenType.Ident:
                switch (lexer.peekToken().type) {
                    case TokenType.PlusAssign | TokenType.MinusAssign | TokenType.AsteriskAssign | TokenType.SlashAssign | TokenType.PercentAssign:
                        block.addNode(parseVariableAssignOp());
                    case TokenType.Assign: block.addNode(parseVariableAssign());
                    default: block.addNode(parseStatement());
                }
            case TokenType.Illegal:
                error.illegalToken(currentToken);
            default:
                block.addNode(parseStatement());
        }
    }
}
