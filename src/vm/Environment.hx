package vm;

import object.Object;

class Environment {

    final variables:Array<Object> = [];

    public function new() {}

    public function setVariable(index:Int, value:Object) {            
        variables[index] = value;
    }

    public function getVariable(index:Int):Object {
        return variables[index];
    }

    public function hasVariable(index:Int):Bool {
        return variables[index] != null;
    }
}