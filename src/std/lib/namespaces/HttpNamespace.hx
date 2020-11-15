package std.lib.namespaces;

import object.ClosureObj;
import sys.thread.Lock;
import object.BooleanObj;
import object.NumberObj;
import object.StringObj;
import object.NullObj;
import sys.Http;
import object.Object;
import evaluator.Evaluator;

private class HttpClient extends MemberObject {

    public function new(evaluator:Evaluator, url:String) {
        super(evaluator);

        final client = new Http(url);

        client.onData = function(data) {
            final newEvaluator = new Evaluator(evaluator.fileData);
        
            final func = cast(members.get("onData"), ClosureObj);
            newEvaluator.callFunction(func, [new StringObj(data, evaluator)]);
        };

        client.onStatus = function(status) {
            final newEvaluator = new Evaluator(evaluator.fileData);
        
            final func = cast(members.get("onStatus"), ClosureObj);
            newEvaluator.callFunction(func, [new NumberObj(status, evaluator)]);
        };
        
        addFunctionMember("onData", 1, function(parameters) {
            return new NullObj(evaluator);
        });

        addFunctionMember("onStatus", 1, function(parameters) {
            return new NullObj(evaluator);
        });

        addFunctionMember("request", 1, function(p) {
            assertParameterType(p[0], ObjectType.Boolean);
            final post = cast(p[0], BooleanObj).value;
            
            client.request(post);

            return new NullObj(evaluator);
        });

        addFunctionMember("addHeader", 2, function(p) {
            assertParameterType(p[0], ObjectType.String);
            assertParameterType(p[1], ObjectType.String);
            final header = cast(p[0], StringObj).value;
            final value = cast(p[1], StringObj).value;

            client.addHeader(header, value);

            return new NullObj(evaluator);
        });

        addFunctionMember("addParameter", 2, function(p) {
            assertParameterType(p[0], ObjectType.String);
            assertParameterType(p[1], ObjectType.String);
            final name = cast(p[0], StringObj).value;
            final value = cast(p[0], StringObj).value;

            client.addParameter(name, value);

            return new NullObj(evaluator); 
        });

        addFunctionMember("setPostData", 1, function(p) {
            assertParameterType(p[0], ObjectType.String);
            final data = cast(p[0], StringObj).value;

            client.setPostData(data);

            return new NullObj(evaluator);
        });
    }
}

class HttpNamespace extends MemberObject {

    public static final name = "Http";

    public function new(evaluator:Evaluator) {
        super(evaluator);

        addFunctionMember("Client", 1, function(p) {
            assertParameterType(p[0], ObjectType.String);
            final url = cast(p[0], StringObj).value;

            return new HttpClient(evaluator, url).getMembers();
        });
    }
}