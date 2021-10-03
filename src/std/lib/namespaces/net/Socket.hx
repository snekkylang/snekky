package std.lib.namespaces.net;

import haxe.io.Bytes;
import object.NumberObj;
import sys.net.Host;
import object.Object.ObjectType;
import object.StringObj;
import object.NullObj;
import vm.VirtualMachine;
import sys.net.Socket as SysSocket;

class Socket extends MemberObject {

    final socket:SysSocket;

    public function new(vm:VirtualMachine, socket:SysSocket) {
        super(vm);

        this.socket = socket;
    }

    override function initMembers() {
        addFunctionMember("write", [ObjectType.String], function(p) {
            final msg = cast(p[0], StringObj).value;
            
            socket.write(msg);

            return new NullObj(vm);
        });

        addFunctionMember("writeHex", [ObjectType.String], function(p) {
            final msg = cast(p[0], StringObj).value;
            
            socket.output.write(Bytes.ofHex(msg));

            return new NullObj(vm);
        });

        addFunctionMember("read", [ObjectType.Number], function(p) {
            final length = Std.int(cast(p[0], NumberObj).value);

            final msg = socket.input.read(length).toString();

            return try {
                new StringObj(msg, vm);
            } catch (err) {
                new NullObj(vm);
            }
        });

        addFunctionMember("readHex", [ObjectType.Number], function(p) {
            final length = Std.int(cast(p[0], NumberObj).value);

            return try {
                new StringObj(socket.input.read(length).toHex(), vm);
            } catch (err) {
                new NullObj(vm);
            }
        });

        addFunctionMember("readLine", [], function(p) {
            return try {
                new StringObj(socket.input.readLine(), vm);
            } catch (err) {
                new NullObj(vm);
            };
        });

        addFunctionMember("connect", [ObjectType.String, ObjectType.Number], function(p) {
            final host = cast(p[0], StringObj).value;
            final port = Std.int(cast(p[1], NumberObj).value);

            socket.connect(new Host(host), port);
            socket.setBlocking(true);

            return new NullObj(vm);
        });

        addFunctionMember("close", [], function(p) {
            socket.close();

            return new NullObj(vm);
        });

        addFunctionMember("accept", [], function(p) {
            return new Socket(vm, socket.accept()).getMembers();
        });

        addFunctionMember("bind", [ObjectType.String, ObjectType.Number], function(p) {
            final host = cast(p[0], StringObj).value;
            final port = Std.int(cast(p[1], NumberObj).value);

            socket.bind(new Host(host), port);

            return new NullObj(vm);
        });

        addFunctionMember("listen", [ObjectType.Number], function(p) {
            final connections = Std.int(cast(p[0], NumberObj).value);

            socket.listen(connections);

            return new NullObj(vm);
        });
    }
}
