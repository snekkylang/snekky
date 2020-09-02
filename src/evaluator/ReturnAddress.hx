package evaluator;

import object.objects.FunctionObj;

class ReturnAddress {

    public final byteIndex:Int;
    public final calledFunction:FunctionObj;

    public function new(byteIndex:Int, calledFunction:FunctionObj) {
        this.byteIndex = byteIndex;
        this.calledFunction = calledFunction;
    }
}