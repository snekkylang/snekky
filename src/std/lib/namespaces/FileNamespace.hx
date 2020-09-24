package std.lib.namespaces;

import sys.io.File;
import object.Object;
import evaluator.Evaluator;

class FileNamespace extends Namespace {

    public static final name = "File";

    public function new(evaluator:Evaluator) {
        super(evaluator);

        addFunctionMember("get_content", 1, function(parameters) {
            switch (parameters[0]) {
                case Object.String(path):
                    final content = File.getContent(path);
                    return Object.String(content);
                default: error("failed to open file");
            }

            return Object.Null;
        });
    }
}