package parser.nodes.operators;

import parser.nodes.operators.Operator.OperatorAssociativity;

class Plus extends Operator {

    public function new(line:Int) {
        super();
        
        this.line = line;
        this.type = NodeType.Plus;
        this.precedence = 4;
        this.associativity = OperatorAssociativity.Left;
    }
}
