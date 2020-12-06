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

        addFunctionMember("write", [ObjectType.String], function(p) {
            final msg = cast(p[0], StringObj).value;
            
            socket.write(msg);

            return new NullObj(evaluator);
        });

        addFunctionMember("writeHex", [ObjectType.String], function(p) {
            final msg = cast(p[0], StringObj).value;
            
            socket.output.write(Bytes.ofHex(msg));

            return new NullObj(evaluator);
        });

        addFunctionMember("read", [ObjectType.Number], function(p) {
            final length = Std.int(cast(p[0], NumberObj).value);

            final msg = socket.input.read(length).toString();

            return new StringObj(msg, evaluator);
        });

        addFunctionMember("readHex", [ObjectType.Number], function(p) {
            final length = Std.int(cast(p[0], NumberObj).value);

            final msg = socket.input.read(length).toHex();

            return new StringObj(msg, evaluator);
        });

        addFunctionMember("readLine", [], function(p) {
            return new StringObj(socket.input.readLine(), evaluator);
        });

        addFunctionMember("connect", [], function(p) {
            socket.connect(new Host(host), port);
            socket.setBlocking(true);

            return new NullObj(evaluator);
        });

        addFunctionMember("close", [], function(p) {
            socket.close();

            return new NullObj(evaluator);
        });
    }
}
