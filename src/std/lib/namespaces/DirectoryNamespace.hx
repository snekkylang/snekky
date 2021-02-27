package std.lib.namespaces;

import object.Object;
import object.NullObj;
import sys.FileSystem;
import object.StringObj;
import object.BooleanObj;
import vm.VirtualMachine;

class DirectoryNamespace extends MemberObject {

    public static final name = "Directory";

    public function new(vm:VirtualMachine) {
        super(vm);

        addFunctionMember("create", [ObjectType.String], function(p) {
            final path = cast(p[0], StringObj).value;

            try {
                FileSystem.createDirectory(path);
            } catch (e) {
                error("failed to create directory");
            }

            return new NullObj(vm);
        });

        addFunctionMember("delete", [ObjectType.String], function(p) {
            final path = cast(p[0], StringObj).value;

            try {
                FileSystem.deleteDirectory(path);
            } catch (e) {
                error("failed to delete directory");
            }

            return new NullObj(vm);
        });

        addFunctionMember("exists", [ObjectType.String], function(p) {
            final path = cast(p[0], StringObj).value;

            return new BooleanObj(FileSystem.exists(path), vm);
        });

        addFunctionMember("isDirectory", [ObjectType.String], function(p) {
            final path = cast(p[0], StringObj).value;

            try {
                return new BooleanObj(FileSystem.isDirectory(path), vm);
            } catch (e) {
                error("failed to find system entry");
            }

            return new NullObj(vm);
        });
    }
}