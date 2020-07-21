package parser.nodes.operators;

import parser.nodes.operators.Operator.OperatorAssociativity;

class Multiply extends Operator {

    public function new(line:Int) {
        super();
        
        this.line = line;
        this.type = NodeType.Multiply;
        this.precedence = 3;
        this.associativity = OperatorAssociativity.Left;
    }
}
