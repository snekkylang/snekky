package ast.nodes;

import lexer.Position;

class RegexNode extends Node {

    public final pattern:ExpressionNode;
    public final flags:ExpressionNode;

    public function new(position:Position, pattern:ExpressionNode, flags:ExpressionNode) {
        super(position, NodeType.Regex);

        this.pattern = pattern;
        this.flags = flags;
    }
}