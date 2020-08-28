package error;

import parser.Parser;
import lexer.Lexer;

class ParserError {

    final lexer:Lexer;
    final parser:Parser;

    public function new(lexer:Lexer, parser:Parser) {
        this.lexer = lexer;
        this.parser = parser;

        Console.logPrefix = "";
    }

    function getMinIndentation(code:Array<String>):Int {
        var min = -1;

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

            if (spaces < min || min == -1) {
                min = spaces;
            }
        }

        return min;
    }

    function repeatString(length:Int, s:String):String {
        final buffer = new StringBuf();

        for (i in 0...length) {
            buffer.add(s);
        }

        return buffer.toString();
    }

    function clamp(min:Int, max:Int, value:Int):Int {
        return if (value < min) {
            min;
        } else if (value > max) {
            max;
        } else {
            value;
        }
    }

    function printCode() {
        final errorLine = lexer.currentLine;

        final codePreviewFull = lexer.code.split("\n");
        final previewStart = clamp(1, errorLine - 2, errorLine - 2);
        final previewEnd = clamp(1, codePreviewFull.length + 1, errorLine + 3) ;

        final codePreview = codePreviewFull.slice(previewStart, previewEnd);
        final minIndentation = getMinIndentation(codePreview);

        final lineCountWidth = Std.string(errorLine + 3).length;

        for (i in previewStart...previewEnd) {
            final lineCount = StringTools.rpad(Std.string(i), " ", lineCountWidth);
            final codeLine = codePreviewFull[i - 1].substring(minIndentation);

            if (i == errorLine) {
                final literalLength = parser.currentToken.literal.length;

                final codeLineHighlighted = new StringBuf();
                codeLineHighlighted.add(codeLine.substring(0, lexer.currentLineChar - literalLength - 1));
                codeLineHighlighted.add("<#DE4A3F>");
                codeLineHighlighted.add(codeLine.substr(lexer.currentLineChar - literalLength - 1, literalLength));
                codeLineHighlighted.add("</>");
                codeLineHighlighted.add(codeLine.substr(lexer.currentLineChar - 1, codeLineHighlighted.length));

                Console.log('   $lineCount | ${codeLineHighlighted.toString()}');

                final underline = '${repeatString(lexer.currentLineChar - literalLength - 1, " ")}${repeatString(literalLength, "~")}';

                Console.log('   ${repeatString(lineCountWidth, " ")} | <#DE4A3F>$underline</>');
            } else {
                Console.log('   $lineCount | $codeLine');
            }
        } 
    }

    function printHead(message:String) {
        final filename = lexer.filename;
        final line = lexer.currentLine;
        final lineChar = lexer.currentLineChar - parser.currentToken.literal.length;

        Console.log('<b>$filename:$line:$lineChar</> <#DE4A3F>error:</> $message.');
    }

    public function unexpectedToken(expected:String) {
        final currentToken = parser.currentToken;
        
        printHead('unexpected token `${currentToken.literal}` (${currentToken.type})');
        Console.log('Expected $expected.');

        printCode();

        Sys.exit(0);
    }

    public function unexpectedEof() {
        printHead('unexpected end of file');

        printCode();

        Sys.exit(0);
    }

    public function illegalToken() {
        final currentToken = parser.currentToken;
        printHead('illegal token `${currentToken.literal}` (${currentToken.type})');

        printCode();

        Sys.exit(0);
    }
}