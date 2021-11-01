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
    }

    override function initMembers() {
        addFunctionMember("trace", [null], function(p) {
            final fileName = vm.fileNameTable.resolve(vm.instructions.position);
            final position = vm.lineNumberTable.resolve(vm.instructions.position);

            final s = '$fileName:${position.line}: ${p[0]}';
            #if target.sys
            Sys.println(s);
            #else
            js.Browser.console.log(s);
            #end

            return p[0];
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

        addFunctionMember("time", [], function(p) {
            #if js
            return new NumberObj(Date.now().getTime(), vm);
            #else
            return new NumberObj(Sys.time() * 1000, vm);
            #end
        });

        #if target.sys
        addFunctionMember("readLine", [], function(p) {
            final input = Sys.stdin().readLine();

            return new StringObj(input, vm);
        });
        #end

        #if target.sys
        // TODO: Maybe this method should be removed.
        addFunctionMember("sleep", [ObjectType.Number], function(p) {
            final time = cast(p[0], NumberObj).value;
            Sys.sleep(time);

            return new NullObj(vm);
        });
        #end

        #if target.sys
        addFunctionMember("exit", [ObjectType.Number], function(p) {
            final code = Std.int(cast(p[0], NumberObj).value);
            Sys.exit(code);

            return new NullObj(vm);
        });
        #end
    }
}