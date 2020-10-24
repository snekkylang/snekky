package ast.nodes;

class RangeNode extends Node {

    public final start:ExpressionNode;
    public final end:ExpressionNode;
    public final inclusive:Bool;

    public function new(position:Int, start:ExpressionNode, end:ExpressionNode, inclusive:Bool) {
        super(position, NodeType.Range);

        this.start = start;
        this.end = end;
        this.inclusive = inclusive;
    }
}