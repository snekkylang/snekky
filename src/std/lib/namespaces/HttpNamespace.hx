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

    public function new(vm:VirtualMachine, url:String) {
        super(vm);

        final client = new Http(url);

        client.onData = function(data) {
            final newVirtualMachine = new VirtualMachine(vm.fileData);
        
            if (members.exists("onData")) {
                final func = cast(members.get("onData"), ClosureObj);
                try {
                    newVirtualMachine.callFunction(func, [new StringObj(data, vm)]);
                } catch (err) {}
            }
        };

        client.onStatus = function(status) {
            final newVirtualMachine = new VirtualMachine(vm.fileData);
        
            if (members.exists("onStatus")) {
                final func = cast(members.get("onStatus"), ClosureObj);
                try {
                    newVirtualMachine.callFunction(func, [new NumberObj(status, vm)]);
                } catch (err) {}
            }
        };

        client.onError = function(err) {
            final newVirtualMachine = new VirtualMachine(vm.fileData);
        
            if (members.exists("onError")) {
                final func = cast(members.get("onError"), ClosureObj);
                try {
                    newVirtualMachine.callFunction(func, [new StringObj(err, vm)]);
                } catch (err) {}
            }    
        };

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

        addFunctionMember("Client", [ObjectType.String], function(p) {
            final url = cast(p[0], StringObj).value;

            return new HttpClient(vm, url).getMembers();
        });
    }
}