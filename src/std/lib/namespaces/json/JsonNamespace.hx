package std.lib.namespaces.json;

import object.StringObj;
import object.Object.ObjectType;
import object.NullObj;
import evaluator.Evaluator;

class JsonNamespace extends MemberObject {

    public static final name = "Json";

    public function new(evaluator:Evaluator) {
        super(evaluator);

        addFunctionMember("encode", 1, function(p) {
            return try {
                new StringObj(JsonEncoder.encode(p[0]), evaluator);
            } catch (e) {
                error(e.message);
                null;
            }
        });

        addFunctionMember("decode", 1, function(p) {
            assertParameterType(p[0], ObjectType.String);
            final json = cast(p[0], StringObj).value;

            return try {
                final decoder = new JsonDecoder(json, evaluator);
                decoder.decode();
            } catch (e) {
                error(e.message);
                null;
            }
        });
    }
}