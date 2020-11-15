package std.lib.namespaces.net;

import haxe.io.Bytes;
import object.BooleanObj;
import object.NumberObj;
import sys.net.Host;
import object.Object.ObjectType;
import object.StringObj;
import object.NullObj;
import evaluator.Evaluator;

class Socket extends MemberObject {

    public function new(evaluator:Evaluator, host:String, port:Int, secure:Bool) {
        super(evaluator);

        final socket = secure ? new sys.ssl.Socket() : new sys.net.Socket();

        addFunctionMember("write", 2, function(p) {
            assertParameterType(p[0], ObjectType.String);
            final msg = cast(p[0], StringObj).value;

            assertParameterType(p[1], ObjectType.Boolean);
            final hex = cast(p[1], BooleanObj).value;
            
            if (hex) {
                socket.output.write(Bytes.ofHex(msg));
            } else {
                socket.write(msg);
            }

            return new NullObj(evaluator);
        });

        addFunctionMember("read", 2, function(p) {
            assertParameterType(p[0], ObjectType.Number);
            final length = Std.int(cast(p[0], NumberObj).value);

            assertParameterType(p[1], ObjectType.Boolean);
            final hex = cast(p[1], BooleanObj).value;

            final msg = if (hex) {
                socket.input.read(length).toHex();
            } else {
                socket.input.read(length).toString();
            }

            return new StringObj(msg, evaluator);
        });

        addFunctionMember("readLine", 0, function(p) {
            return new StringObj(socket.input.readLine(), evaluator);
        });

        addFunctionMember("connect", 0, function(p) {
            socket.connect(new Host(host), port);
            socket.setBlocking(true);

            return new NullObj(evaluator);
        });

        addFunctionMember("close", 0, function(p) {
            socket.close();

            return new NullObj(evaluator);
        });
    }
}
