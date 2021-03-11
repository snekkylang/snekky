package vm;

import object.Function;
import object.Object;

class Frame {

    public final env:Environment;
    public final parent:Frame;
    public final returnAddress:Int;
    public final calledFunction:Function;
    public final expectedStackSize:Int;

    public function new(parent:Frame, returnAddress:Int, calledFunction:Function, expectedStackSize) {
        this.parent = parent;
        this.returnAddress = returnAddress;
        this.calledFunction = calledFunction;
        this.env = new Environment();
        this.expectedStackSize = expectedStackSize;
    }

    public function getVariable(index:Int) {
        final v = env.getVariable(index);

        if (v == null && parent != null) {
            return parent.getVariable(index);
        }

        return v;
    }

    public function setVariable(index:Int, value:Object) {
        if (parent != null && parent.env.hasVariable(index) && !env.hasVariable(index)) {
            parent.env.setVariable(index, value);
        } else {
            env.setVariable(index, value);
        }
    }
}