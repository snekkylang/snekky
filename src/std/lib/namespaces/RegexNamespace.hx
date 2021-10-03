package std.lib.namespaces;

import object.BooleanObj;
import object.Object.ObjectType;
import object.StringObj;
import vm.VirtualMachine;

class Regex extends MemberObject {

    final regex:EReg;

    public function new(vm:VirtualMachine, regex:EReg) {
        super(vm);

        this.regex = regex;
    }

    override function initMembers() {
        addFunctionMember("match", [ObjectType.String], function(p) {
            final s = cast(p[0], StringObj).value;

            return new BooleanObj(regex.match(s), vm);
        });

        addFunctionMember("replace", [ObjectType.String, ObjectType.String], function(p) {
            final s = cast(p[0], StringObj).value;
            final by = cast(p[1], StringObj).value;

            return new StringObj(regex.replace(s, by), vm);
        });
    }
}

class RegexNamespace extends MemberObject {

    public static final name = "Regex";

    public function new(vm:VirtualMachine) {
        super(vm);
    }

    override function initMembers() {
        addFunctionMember("compile", [ObjectType.String, ObjectType.String], function(p) {
            final pattern = cast(p[0], StringObj).value;
            final flags = cast(p[1], StringObj).value;
            
            return new Regex(vm, new EReg(pattern, flags)).getMembers();
        });
    }
}