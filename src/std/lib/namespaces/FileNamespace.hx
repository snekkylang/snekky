package std.lib.namespaces;

import sys.io.File;
import object.Object;
import evaluator.Evaluator;

class FileNamespace extends Namespace {

    public static final name = "File";

    public function new(evaluator:Evaluator) {
        super(evaluator);

        addFunctionMember("read_utf8", 1, function(parameters) {
            try {
                switch (parameters[0]) {
                    case Object.String(path):
                        final content = File.getContent(path);
                        return Object.String(content);
                    default: error('expected String, got ${parameters[0].getName()}');
                }
            } catch (e) {
                error("failed to open file");
            }

            return Object.Null;
        });

        addFunctionMember("write_utf8", 2, function(parameters) {
            try {
                switch [parameters[0], parameters[1]] {
                    case [Object.String(path), Object.String(value)]:
                        File.saveContent(path, value);
                    default: 'expected String, got ${parameters[0].getName()}';
                }
            } catch (e) {
                error("failed to open file");
            }

            return Object.Null;
        });
    }
}