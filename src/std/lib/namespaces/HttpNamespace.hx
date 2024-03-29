package std.lib.namespaces;

import object.ClosureObj;
import object.BooleanObj;
import object.NumberObj;
import object.StringObj;
import object.NullObj;
import sys.Http;
import object.Object;
import vm.VirtualMachine;

private class HttpClient extends MemberObject {

    final url:String;
    final client:Http;

    public function new(vm:VirtualMachine, url:String) {
        super(vm);

        this.url = url;
        this.client = new Http(url);

        client.onData = function(data) {        
            final func = cast(members.get("onData"), ClosureObj);
            vm.eventLoop.scheduleCall(func, [new StringObj(data, vm)]);
        };

        client.onStatus = function(status) {        
            final func = cast(members.get("onStatus"), ClosureObj);
            vm.eventLoop.scheduleCall(func, [new NumberObj(status, vm)]);
        };
    }

    override function initMembers() {        
        addFunctionMember("onData", [ObjectType.String], function(parameters) {
            return new NullObj(vm);
        });

        addFunctionMember("onStatus", [ObjectType.Number], function(parameters) {
            return new NullObj(vm);
        });

        addFunctionMember("request", [ObjectType.Boolean], function(p) {
            final post = cast(p[0], BooleanObj).value;
            
            client.request(post);

            return new NullObj(vm);
        });

        addFunctionMember("addHeader", [ObjectType.String, ObjectType.String], function(p) {
            final header = cast(p[0], StringObj).value;
            final value = cast(p[1], StringObj).value;

            client.addHeader(header, value);

            return new NullObj(vm);
        });

        addFunctionMember("addParameter", [ObjectType.String, ObjectType.String], function(p) {
            final name = cast(p[0], StringObj).value;
            final value = cast(p[0], StringObj).value;

            client.addParameter(name, value);

            return new NullObj(vm); 
        });

        addFunctionMember("setPostData", [ObjectType.String], function(p) {
            final data = cast(p[0], StringObj).value;

            client.setPostData(data);

            return new NullObj(vm);
        });
    }
}

class HttpNamespace extends MemberObject {

    public static final name = "Http";

    public function new(vm:VirtualMachine) {
        super(vm);
    }

    override function initMembers() {
        addFunctionMember("Client", [ObjectType.String], function(p) {
            final url = cast(p[0], StringObj).value;

            return new HttpClient(vm, url).getMembers();
        });
    }
}