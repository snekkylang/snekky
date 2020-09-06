package evaluator;

import object.ObjectWrapper;

class Environment {

    final variables:Array<ObjectWrapper> = [];

    public function new() {

    }

    public function setVariable(index:Int, value:ObjectWrapper) {
        variables[index] = value;
    }

    public function getVariable(index:Int):ObjectWrapper {
        return variables[index];
    }
}