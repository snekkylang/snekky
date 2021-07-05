package parser;

import ast.nodes.datatypes.FunctionNode.ParameterNode;
import lexer.Position;
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
    final isRepl:Bool;

    public function new(lexer:Lexer, isRepl:Bool) {
        this.lexer = lexer;
        this.isRepl = isRepl;

        ast = new FileNode(new Position(1, 1, 0), lexer.filename, lexer.code);
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

    public function parseNumberDec():NumberNode {
        final nodePos = currentToken.position;
        final n = Std.parseFloat(currentToken.literal);
        nextToken();
        return new NumberNode(nodePos, n);
    }

    public function parseNumberHex():Node {
        final nodePos = currentToken.position;
        final n = Std.parseInt(currentToken.literal);
        nextToken();
        return new NumberNode(nodePos, n);
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

        nextToken();

        return block;
    }

    public function parseFunction():FunctionNode {
        final nodePos = currentToken.position;

        assertToken(TokenType.LParen, "`(`");

        nextToken();

        final parameters:Array<ParameterNode> = [];

        while (currentToken.type != TokenType.RParen) {
            var mutable = false;
            if (currentToken.type == TokenType.Mut) {
                mutable = true;
                nextToken();
            }

            if (currentToken.type == TokenType.Ident) {
                final param = new ParameterNode(currentToken.position, new IdentNode(currentToken.position, currentToken.literal), mutable);
                parameters.push(param);
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

        return new ExpressionNode(nodePos, new IndexNode(nodePos, target, index));
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
                    assertToken(TokenType.Ident, "identifier");
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

    function parseContinue():ContinueNode {
        final nodePos = currentToken.position;
        nextToken();

        assertSemicolon();
        nextToken();

        return new ContinueNode(nodePos);
    }

    public function parseIf():IfNode {
        final nodePos = currentToken.position;

        nextToken();

        final condition = expressionParser.parseExpression();

        assertToken(TokenType.LBrace, "`{`");

        final consequence = parseBlock();
        var alternative:Node = null;

        if (currentToken.type == TokenType.Else) {
            nextToken();

            alternative = if (currentToken.type == TokenType.If) {
                parseIf();
            } else {
                assertToken(TokenType.LBrace, "`{`");

                parseBlock();
            }
        }

        return new IfNode(nodePos, condition, consequence, alternative);
    }

    function parseWhile():WhileNode {
        final nodePos = currentToken.position;

        nextToken();

        final condition = expressionParser.parseExpression();

        assertToken(TokenType.LBrace, "`{`");

        final block = parseBlock();

        return new WhileNode(nodePos, condition, block);
    }

    public function parseWhen():WhenNode {
        final nodePos = currentToken.position;

        nextToken();

        final condition = if (currentToken.type != TokenType.LBrace) {
            expressionParser.parseExpression();
        } else null;

        assertToken(TokenType.LBrace, "`{`");

        nextToken();

        var elseCase:Node = null;
        final cases:Array<WhenNode.Case> = [];
        while (currentToken.type != TokenType.RBrace) {
            if (currentToken.type == TokenType.Else) {
                nextToken();
                assertToken(TokenType.Arrow, "`=>`");
                nextToken();
                final consequence = if (currentToken.type == TokenType.LBrace) {
                    new ExpressionNode(currentToken.position, parseBlock());
                } else { 
                    expressionParser.parseExpression();
                }

                elseCase = if (currentToken.type == TokenType.Semicolon) {
                    nextToken();
                    new StatementNode(nodePos, consequence);
                } else consequence;

                assertToken(TokenType.RBrace, "`else` entry must be the last in when-expression");
            } else {
                final condition = expressionParser.parseExpression();
                assertToken(TokenType.Arrow, "`=>`");
                nextToken();
                final consequence = if (currentToken.type == TokenType.LBrace) {
                    new ExpressionNode(currentToken.position, parseBlock());
                } else { 
                    expressionParser.parseExpression();
                }

                if (currentToken.type == TokenType.Semicolon) {
                    nextToken();
                    cases.push({condition: condition, consequence: new StatementNode(nodePos, consequence)});
                } else {
                    cases.push({condition: condition, consequence: consequence});
                }
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

        return new ForNode(nodePos, variable, iterator, block);
    }

    function parseVariableAssign():VariableAssignNode {
        final nodePos = currentToken.position;
        final name = new IdentNode(nodePos, currentToken.literal);

        nextToken();

        inline function readValue():ExpressionNode {
            nextToken();
            return expressionParser.parseExpression();
        }

        final value = switch (currentToken.type) {
            case TokenType.Assign: readValue();
            case TokenType.PlusAssign: new ExpressionNode(nodePos, new OperatorNode(nodePos, NodeType.Add, name, readValue()));
            case TokenType.MinusAssign: new ExpressionNode(nodePos, new OperatorNode(nodePos, NodeType.Subtract, name, readValue()));
            case TokenType.AsteriskAssign: new ExpressionNode(nodePos, new OperatorNode(nodePos, NodeType.Multiply, name, readValue()));
            case TokenType.SlashAssign: new ExpressionNode(nodePos, new OperatorNode(nodePos, NodeType.Divide, name, readValue()));
            case TokenType.PercentAssign: new ExpressionNode(nodePos, new OperatorNode(nodePos, NodeType.Modulo, name, readValue()));
            case TokenType.BitAndAssign: new ExpressionNode(nodePos, new OperatorNode(nodePos, NodeType.BitAnd, name, readValue()));
            case TokenType.BitOrAssign: new ExpressionNode(nodePos, new OperatorNode(nodePos, NodeType.BitOr, name, readValue()));
            case TokenType.BitXorAssign: new ExpressionNode(nodePos, new OperatorNode(nodePos, NodeType.BitXor, name, readValue()));
            case TokenType.BitShiftLeftAssign: new ExpressionNode(nodePos, new OperatorNode(nodePos, NodeType.BitShiftLeft, name, readValue()));
            case TokenType.BitShiftRightAssign: new ExpressionNode(nodePos, new OperatorNode(nodePos, NodeType.BitShiftRight, name, readValue()));
            default: 
                assertToken(TokenType.Assign, "`=`");
                null;
        }

        assertSemicolon();
        nextToken();

        return new VariableAssignNode(nodePos, name, value);
    }

    function parseStatement():Node {
        final nodePos = currentToken.position;
        final expression = expressionParser.parseExpression();

        inline function readValue():ExpressionNode {
            nextToken();
            final value = expressionParser.parseExpression();
            assertSemicolon();
            nextToken();

            return value;
        }

        final statement = switch (currentToken.type) {
            case TokenType.Assign: new IndexAssignNode(nodePos, expression, readValue());
            case TokenType.PlusAssign: new IndexAssignNode(nodePos, expression, new ExpressionNode(nodePos, new OperatorNode(nodePos, NodeType.Add, expression, readValue())));
            case TokenType.MinusAssign: new IndexAssignNode(nodePos, expression, new ExpressionNode(nodePos, new OperatorNode(nodePos, NodeType.Subtract, expression, readValue())));
            case TokenType.AsteriskAssign: new IndexAssignNode(nodePos, expression, new ExpressionNode(nodePos, new OperatorNode(nodePos, NodeType.Multiply, expression, readValue())));
            case TokenType.SlashAssign: new IndexAssignNode(nodePos, expression, new ExpressionNode(nodePos, new OperatorNode(nodePos, NodeType.Divide, expression, readValue())));
            case TokenType.PercentAssign: new IndexAssignNode(nodePos, expression, new ExpressionNode(nodePos, new OperatorNode(nodePos, NodeType.Modulo, expression, readValue())));
            case TokenType.BitAndAssign: new IndexAssignNode(nodePos, expression, new ExpressionNode(nodePos, new OperatorNode(nodePos, NodeType.BitAnd, expression, readValue())));
            case TokenType.BitOrAssign: new IndexAssignNode(nodePos, expression, new ExpressionNode(nodePos, new OperatorNode(nodePos, NodeType.BitOr, expression, readValue())));
            case TokenType.BitShiftLeftAssign: new IndexAssignNode(nodePos, expression, new ExpressionNode(nodePos, new OperatorNode(nodePos, NodeType.BitShiftLeft, expression, readValue())));
            case TokenType.BitShiftRightAssign: new IndexAssignNode(nodePos, expression, new ExpressionNode(nodePos, new OperatorNode(nodePos, NodeType.BitShiftRight, expression, readValue())));
            case TokenType.BitXorAssign: new IndexAssignNode(nodePos, expression, new ExpressionNode(nodePos, new OperatorNode(nodePos, NodeType.BitXor, expression, readValue())));
            default:
                if (currentToken.type == TokenType.RBrace || (isRepl && currentToken.type == TokenType.Eof)) {
                    expression;
                } else {
                    assertSemicolon();
                    nextToken();
                    new StatementNode(nodePos, expression);
                }  
        }

        return statement;
    }

    function parseImport():FileNode {
        nextToken();

        assertToken(TokenType.String, "string containing path to source file");
        final fileName = '${currentToken.literal}.snek';
        nextToken();
        assertSemicolon();
        nextToken();
        #if target.sys
        final code = try {
            sys.io.File.getContent(fileName);
        } catch (e) {
            error.importFailed(currentToken, fileName);

            return null;
        }
        #else
        final code = "";
        throw "Imports not supported on this target";
        #end

        final lexer = new Lexer(fileName, code);

        final parser = new Parser(lexer, isRepl);
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
            case TokenType.Let | TokenType.Mut: block.addNode(parseVariable());
            case TokenType.Return: block.addNode(parseReturn());
            case TokenType.If: block.addNode(parseIf());
            case TokenType.While: block.addNode(parseWhile());
            case TokenType.For: block.addNode(parseFor());
            case TokenType.When: block.addNode(parseWhen());
            case TokenType.Break: block.addNode(parseBreak());
            case TokenType.Continue: block.addNode(parseContinue());
            #if target.sys
            case TokenType.Import: block.addNode(parseImport());
            #end
            case TokenType.LBrace:
                if (resolveHashBlockAmbiguity() == NodeType.Block) {
                    block.addNode(parseBlock());
                } else {
                    block.addNode(parseStatement());
                }
            case TokenType.Ident:
                switch (lexer.peekToken().type) {
                    case TokenType.Assign | TokenType.PlusAssign | TokenType.MinusAssign | TokenType.SlashAssign
                        | TokenType.AsteriskAssign | TokenType.BitAndAssign | TokenType.BitOrAssign | TokenType.BitShiftLeftAssign
                        | TokenType.BitShiftRightAssign | TokenType.BitXorAssign | TokenType.PercentAssign:
                        block.addNode(parseVariableAssign());
                    default: block.addNode(parseStatement());
                }
            case TokenType.Illegal: error.illegalToken(currentToken);
            default: block.addNode(parseStatement());
        }
    }
}
