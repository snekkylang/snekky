package error;

import lexer.Token;

class CompileError {

    static final init = {
        Console.logPrefix = "";
    };

    static function getMinIndentation(code:Array<String>):Int {
        var min = 0;

        for (line in code) {
            if (line.length == 0) {
                continue;
            }

            var spaces = 0;

            for (i in 0...line.length) {
                if (line.charAt(i) == " ") {
                    spaces++;
                } else {
                    break;
                }   
            }

            if (spaces < min) {
                min = spaces;
            }
        }

        return min;
    }

    static function repeatString(length:Int, s:String):String {
        final buffer = new StringBuf();

        for (i in 0...length) {
            buffer.add(s);
        }

        return buffer.toString();
    }

    static function clamp(min:Int, max:Int, value:Int):Int {
        return if (value < min) {
            min;
        } else if (value > max) {
            max;
        } else {
            value;
        }
    }

    static function printCode(token:Token, code:String) {
        final errorLine = token.line;

        final codePreviewFull = code.split("\n");
        final previewStart = clamp(1, errorLine - 2, errorLine - 2);
        final previewEnd = clamp(1, codePreviewFull.length + 1, errorLine + 3) ;

        final codePreview = codePreviewFull.slice(previewStart - 1, previewEnd);
        final minIndentation = getMinIndentation(codePreview);

        final lineCountWidth = Std.string(errorLine + 3).length;

        for (i in previewStart...previewEnd) {
            final lineCount = StringTools.rpad(Std.string(i), " ", lineCountWidth);
            final codeLine = codePreviewFull[i - 1].substring(minIndentation);

            if (i == errorLine) {
                final literalLength = token.literal.length;

                final codeLineHighlighted = new StringBuf();
                codeLineHighlighted.add(codeLine.substring(0, token.linePos - minIndentation));
                codeLineHighlighted.add("<#DE4A3F>");
                codeLineHighlighted.add(codeLine.substr(token.linePos - minIndentation, literalLength));
                codeLineHighlighted.add("</>");
                codeLineHighlighted.add(codeLine.substr(token.linePos - minIndentation + literalLength, codeLineHighlighted.length));

                Console.log('   $lineCount | ${codeLineHighlighted.toString()}');

                final underline = '${repeatString(token.linePos - minIndentation, " ")}${repeatString(literalLength, "~")}';

                Console.log('   ${repeatString(lineCountWidth, " ")} | <#DE4A3F>$underline</>');
            } else {
                Console.log('   $lineCount | $codeLine');
            }
        } 
    }

    static function printHead(token:Token, message:String) {
        final filename = token.filename;
        final line = token.line;
        final linePos = token.linePos;

        Console.log('<b>$filename:$line:$linePos</> <#DE4A3F>error:</> $message.');
    }

    public static function unexpectedToken(token:Token, code:String, expected:String) {
        printHead(token, 'unexpected token `${token.literal}` (${token.type})');
        Console.log('Expected $expected.');

        printCode(token, code);

        Sys.exit(0);
    }

    public static function unexpectedEof(token:Token, code:String) {
        printHead(token, 'unexpected end of file');

        printCode(token, code);

        Sys.exit(0);
    }

    public static function illegalToken(token:Token, code:String) {
        printHead(token, 'illegal token `${token.literal}` (${token.type})');

        printCode(token, code);

        Sys.exit(0);
    }
}