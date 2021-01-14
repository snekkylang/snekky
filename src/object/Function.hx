package object;

import vm.VirtualMachine;
import object.Object.ObjectType;

class Function extends Object {

    public final parametersCount:Int;

    public function new(type:ObjectType, parametersCount:Int, vm:VirtualMachine) {
        super(type, vm);

        this.parametersCount = parametersCount;
    }
}