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

    public function new(vm:VirtualMachine, socket:SysSocket) {
        super(vm);

        addFunctionMember("write", [ObjectType.String], function(p) {
            final msg = cast(p[0], StringObj).value;
            
            try {
                socket.peer();
                socket.write(msg);
            } catch (err) {
                error("failed to write to socket. connection closed");
                null;
            }

            return new NullObj(vm);
        });

        addFunctionMember("writeHex", [ObjectType.String], function(p) {
            final msg = cast(p[0], StringObj).value;

            try {
                socket.peer();
                socket.output.write(Bytes.ofHex(msg));
            } catch (err) {
                error("failed to write to socket. connection closed");
                null;
            }

            return new NullObj(vm);
        });

        addFunctionMember("read", [ObjectType.Number], function(p) {
            final length = Std.int(cast(p[0], NumberObj).value);

            return try {
                socket.peer();
                new StringObj(socket.input.read(length).toString(), vm);
            } catch (err) {
                error("failed to read from socket. connection closed");
                null;
            }
        });

        addFunctionMember("readHex", [ObjectType.Number], function(p) {
            final length = Std.int(cast(p[0], NumberObj).value);

            return try {
                socket.peer();
                new StringObj(socket.input.read(length).toHex(), vm);
            } catch (err) {
                error("failed to read from socket. connection closed");
                null;
            }
        });

        addFunctionMember("readLine", [], function(p) {
            return try {
                socket.peer();
                new StringObj(socket.input.readLine(), vm);
            } catch (err) {
                error("failed to read from socket. connection closed");
                null;
            }
        });

        addFunctionMember("connect", [ObjectType.String, ObjectType.Number], function(p) {
            final host = cast(p[0], StringObj).value;
            final port = Std.int(cast(p[1], NumberObj).value);

            try {
                socket.connect(new Host(host), port);
                socket.setBlocking(true);
            } catch (err) {
                error('failed to establishment connection to $host:$port');
                null;
            }

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

            try {
                socket.bind(new Host(host), port);
            } catch (err) {
                error('failed to bind socket to $host:$port. address already in use');
                null;
            }

            return new NullObj(vm);
        });

        addFunctionMember("listen", [ObjectType.Number], function(p) {
            final connections = Std.int(cast(p[0], NumberObj).value);

            try {
                socket.listen(connections);
            } catch (err) {
                error("failed to listen");
                null;
            }

            return new NullObj(vm);
        });
    }
}
