package compiler;

import parser.nodes.operators.Operator;
import object.objects.Object;
import object.objects.IntObject;
import haxe.io.BytesBuffer;
import parser.nodes.datatypes.Int.IntN;
import code.Code;
import code.OpCode;
import parser.nodes.*;
import parser.nodes.Node;

class Compiler {

    public final constants:Array<Object> = [];
    public final instructions = new BytesBuffer();

    public function new() {

    }

    public function compile(node:Node) {
        switch(node.type) {
            case Block:
                final cBlock = cast(node, Block);
                for (blockNode in cBlock.body) {
                    compile(blockNode);
                }

            case Expression:
                final cExpression = cast(node, Expression);
                compile(cExpression.value);
                emit(OpCode.Pop, []);
            case Plus | Multiply:
                final cOperator = cast(node, Operator);
                compile(cOperator.left);
                compile(cOperator.right);

                switch (cOperator.type) {
                    case Plus: emit(OpCode.Add, []);
                    case Multiply: emit(OpCode.Multiply, []);
                    default:
                }
            case Int:
                emit(OpCode.Constant, [addConstant(node)]);
            default:
        }
    }

    function emit(op:OpCode, operands:Array<Int>) {
        final instruction = Code.make(op, operands);
        instructions.add(instruction);
    }

    function addConstant(node:Node):Int {
        switch (node.type) {
            case Int:
                constants.push(new IntObject(cast(node, IntN).value));
            default:
        }

        return constants.length - 1;
    }
}