package ast.nodes;

class RegexNode extends Node {

    public final pattern:ExpressionNode;
    public final flags:ExpressionNode;

    public function new(position:Int, pattern:ExpressionNode, flags:ExpressionNode) {
        super(position, NodeType.Regex);

        this.pattern = pattern;
        this.flags = flags;
    }
}