package std.lib.namespaces.net;

import haxe.io.Bytes;
import object.BooleanObj;
import object.NumberObj;
import sys.net.Host;
import object.Object.ObjectType;
import object.StringObj;
import object.NullObj;
import vm.VirtualMachine;

class Socket extends MemberObject {

    public function new(vm:VirtualMachine, host:String, port:Int, secure:Bool) {
        super(vm);

        final socket = secure ? new sys.ssl.Socket() : new sys.net.Socket();

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

            return new StringObj(msg, vm);
        });

        addFunctionMember("readHex", [ObjectType.Number], function(p) {
            final length = Std.int(cast(p[0], NumberObj).value);

            final msg = socket.input.read(length).toHex();

            return new StringObj(msg, vm);
        });

        addFunctionMember("readLine", [], function(p) {
            return new StringObj(socket.input.readLine(), vm);
        });

        addFunctionMember("connect", [], function(p) {
            socket.connect(new Host(host), port);
            socket.setBlocking(true);

            return new NullObj(vm);
        });

        addFunctionMember("close", [], function(p) {
            socket.close();

            return new NullObj(vm);
        });
    }
}
