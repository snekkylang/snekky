package std;

import std.lib.namespaces.io.IoNamespace;
import std.lib.namespaces.json.*;
import std.lib.namespaces.net.*;
import object.BuiltInFunctionObj;
import std.lib.MemberObject;
import std.lib.namespaces.*;
import vm.VirtualMachine;
import object.Object;

typedef MemberFunction = {parametersCount:Int, memberFunction:Array<Object>->Object};

class BuiltInTable {

    final namespaces:Array<MemberObject>;
    final vm:VirtualMachine;

    public function new(vm:VirtualMachine) {
        this.vm = vm;

        namespaces = [
            new SysNamespace(vm),
            new MathNamespace(vm),
            new NumberNamespace(vm),
            new ObjectNamespace(vm),
            new RangeNamespace(vm),
            new RegexNamespace(vm),
            new JsonNamespace(vm),
            new IoNamespace(vm),
            new StringNamespace(vm),
            #if target.sys
            new EventLoopNamespace(vm),
            new FileNamespace(vm), 
            new HttpNamespace(vm),
            new NetNamespace(vm)
            #end
        ];
    }

    public static function resolveName(name:String):Int {
        return [
            SysNamespace.name,
            MathNamespace.name,
            NumberNamespace.name,
            ObjectNamespace.name,
            RangeNamespace.name,
            RegexNamespace.name,
            JsonNamespace.name,
            IoNamespace.name,
            StringNamespace.name,
            #if target.sys
            EventLoopNamespace.name,
            FileNamespace.name, 
            HttpNamespace.name,
            NetNamespace.name
            #end
        ].indexOf(name);
    }

    public function resolveIndex(index:Int):Object {
        return namespaces[index].getMembers();
    }

    public function callFunction(func:BuiltInFunctionObj) {
        final parameters:Array<Object> = [];

        for (i in 0...func.parametersCount) {
            final parameter = vm.popStack();

            if (func.parameters[i] != null && parameter.type != func.parameters[i]) {
                vm.error.error('expected ${(func.parameters[i])}, got ${parameter.type}'); 
            }

            parameters.push(parameter);
        }

        final returnValue = func.func(parameters);
        vm.stack.add(returnValue);
        vm.popFrame();
    }
}
