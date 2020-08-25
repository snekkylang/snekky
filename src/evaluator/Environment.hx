package evaluator;

import cpp.Object;

class Environment {

    final variables:Map<Int, Object> = new Map();
    final parent:Environment;

    public function new(parent:Environment) {
        this.parent = parent;
    }

    public function setVariable(index:Int, value:Object) {
        variables.set(index, value);
    }

    public function existsVariable(index:Int):Bool {
        return variables.exists(index);
    }

    public function getVariable(index:Int):Object {
        var currentScope = this;

        while (currentScope != null && !currentScope.existsVariable(index)) {
            currentScope = currentScope.parent;
        }

        return variables.get(index);
    }
}