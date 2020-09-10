package evaluator;

import object.Object;

class ReturnAddress {

    public final byteIndex:Int;
    public final calledFunction:Object;

    public function new(byteIndex:Int, calledFunction:Object) {
        this.byteIndex = byteIndex;
        this.calledFunction = calledFunction;
    }
}