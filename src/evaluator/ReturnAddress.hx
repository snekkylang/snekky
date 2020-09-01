package evaluator;

import object.objects.FunctionObj;

class ReturnAddress {

    public final returnAddress:Int;
    public final calledFunction:FunctionObj;

    public function new(returnAddress:Int, calledFunction:FunctionObj) {
        this.returnAddress = returnAddress;
        this.calledFunction = calledFunction;
    }
}