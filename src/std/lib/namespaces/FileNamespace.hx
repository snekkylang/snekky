package std.lib.namespaces;

import std.lib.namespaces.io.Bytes;
import sys.FileSystem;
import object.NullObj;
import object.StringObj;
import object.BooleanObj;
import sys.io.File;
import object.Object;
import vm.VirtualMachine;

class FileNamespace extends MemberObject {

    public static final name = "File";

    public function new(vm:VirtualMachine) {
        super(vm);
    }

    override function initMembers() {
        addFunctionMember("readBytes", [ObjectType.String], function(p) {
            final path = cast(p[0], StringObj).value;

            try {
                final content = File.getBytes(path);
                return new Bytes(vm, content).getMembers();
            } catch (e) {
                error("failed to open file");
            }

            return new NullObj(vm);
        });

        addFunctionMember("read", [ObjectType.String], function(p) {
            final path = cast(p[0], StringObj).value;

            try {
                final content = File.getContent(path);
                return new StringObj(content, vm);
            } catch (e) {
                error("failed to open file");
            }

            return new NullObj(vm);
        });

        addFunctionMember("write", [ObjectType.String, ObjectType.String], function(p) {
            final path = cast(p[0], StringObj).value;
            final content = cast(p[1], StringObj).value;
            
            try {
                File.saveContent(path, content);
            } catch (e) {
                error("failed to open file");
            }

            return new NullObj(vm);
        });

        addFunctionMember("exists", [ObjectType.String], function(p) {
            final path = cast(p[0], StringObj).value;

            return new BooleanObj(FileSystem.exists(path), vm);
        });

        addFunctionMember("delete", [ObjectType.String], function(p) {
            final path = cast(p[0], StringObj).value;

            try {
                FileSystem.deleteFile(path);
            } catch (e) {
                error("failed to delete file");
            }

            return new NullObj(vm);
        });
    }
}