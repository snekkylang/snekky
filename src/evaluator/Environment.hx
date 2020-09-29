package evaluator;

import object.Object;

class Environment {

    final variables:Array<Array<Object>> = [];
    public var depth = 0;

    public function new() {}

    public function setVariable(index:Int, value:Object) {
        if (variables[index] == null) {
            variables[index] = [];
            variables[index][depth] = value;
        } else if (variables[index][0] != null) {
            variables[index][0] = value;
        } else {
            variables[index][depth] = value;
        }
    }

    public function getVariable(index:Int):Object {
        var i = depth;

        while (i >= 0) {
            if (variables[index][i] != null) {
                return variables[index][i];
            }

            i--;
        }

        return null;
    }
}