package std.lib.namespaces;

import object.Object.ObjectType;
import object.NumberObj;
import object.StringObj;
import object.NullObj;
import vm.VirtualMachine;

class SysNamespace extends MemberObject {

    public static final name = "Sys";

    public function new(vm:VirtualMachine) {
        super(vm);

        addFunctionMember("trace", [null], function(p) {
            final filename = vm.filenameTable.resolve(vm.instructions.position);
            final position = vm.lineNumberTable.resolve(vm.instructions.position);

            final s = '$filename:${position.line}: ${p[0]}';
            #if target.sys
            Sys.println(s);
            #else
            js.Browser.console.log(s);
            #end

            return new NullObj(vm);
        });

        addFunctionMember("println", [null], function(p) {
            #if target.sys
            Sys.println(p[0].toString());
            #else
            js.Browser.console.log(p[0].toString());
            #end

            return new NullObj(vm);
        });

        addFunctionMember("print", [null], function(p) {
            #if target.sys
            Sys.print(p[0].toString());
            #else
            js.Browser.console.log(p[0].toString());
            #end

            return new NullObj(vm);
        });

        addFunctionMember("readLine", [], function(p) {
            #if target.sys
            final input = Sys.stdin().readLine();
            #else
            final input = "";
            throw "Read line not supported on this target";
            #end

            return new StringObj(input, vm);
        });

        addFunctionMember("sleep", [ObjectType.Number], function(p) {
            #if target.sys
            final time = cast(p[0], NumberObj).value;
            
            Sys.sleep(time);
            #else
            throw "unsupported";
            #end

            return new NullObj(vm);
        });

        addFunctionMember("exit", [ObjectType.Number], function(p) {
            #if target.sys
            final code = Std.int(cast(p[0], NumberObj).value);
            
            Sys.exit(code);
            #else
            throw "unsupported";
            #end

            return new NullObj(vm);
        });
    }
}