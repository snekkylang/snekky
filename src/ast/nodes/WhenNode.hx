package ast.nodes;

typedef Case = {condition:ExpressionNode, consequence:Node}

class WhenNode extends Node {

    public final condition:ExpressionNode;
    public final cases:Array<Case>;
    public final elseCase:Node;


    public function new(position:Int, condition:ExpressionNode, cases:Array<Case>, elseCase:Node) {
        super(position, NodeType.When);

        this.condition = condition;
        this.cases = cases;
        this.elseCase = elseCase;
    }
}