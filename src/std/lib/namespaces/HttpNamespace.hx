package std.lib.namespaces;

import sys.Http;
import object.Object;
import evaluator.Evaluator;

private class HttpClient extends MemberObject {

    public function new(evaluator:Evaluator, url:String) {
        super(evaluator);

        final client = new Http(url);

        client.onData = function(data) {
            evaluator.callFunction(members.get("onData"), [Object.String(data)]); 
        };

        client.onStatus = function(status) {
            evaluator.callFunction(members.get("onStatus"), [Object.Float(status)]);  
        };
        
        addFunctionMember("onData", 1, function(parameters) {
            return Object.Null;
        });

        addFunctionMember("onStatus", 1, function(parameters) {
            return Object.Null;
        });

        addFunctionMember("request", 1, function(parameters) {
            switch (parameters[0]) {
                case Object.Float(post): client.request(post == 1);
                default:
            }

            return Object.Null;
        });

        addFunctionMember("addHeader", 2, function(parameters) {
            switch [parameters[0], parameters[1]] {
                case [Object.String(header), Object.String(value)]:
                    client.addHeader(header, value);
                default:
            }

            return Object.Null;
        });

        addFunctionMember("addParameter", 2, function(parameters) {
            switch [parameters[0], parameters[1]] {
                case [Object.String(parameter), Object.String(value)]:
                    client.addParameter(parameter, value);
                default:
            }

            return Object.Null;  
        });

        addFunctionMember("setPostData", 1, function(paramaters) {
            switch (paramaters[0]) {
                case Object.String(data): client.setPostData(data);
                default:
            }

            return Object.Null;
        });
    }
}

class HttpNamespace extends MemberObject {

    public static final name = "Http";

    public function new(evaluator:Evaluator) {
        super(evaluator);

        addFunctionMember("Client", 1, function(parameters) {
            switch (parameters[0]) {
                case Object.String(url): return new HttpClient(evaluator, url).getObject();
                default: 
            }

            return Object.Null;
        });
    }
}