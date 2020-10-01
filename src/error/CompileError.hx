package error;

import lexer.Token;

class CompileError {

    static var init = {
        Console.logPrefix = "";
    }

    final filename:String;
    final code:String;

    public function new(filename:String, code:String) {
        this.filename = filename;
        this.code = code;
    }

    function getMinIndentation(code:Array<String>):Int {
        var min = 2147483647;

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

    function printCode(errorLine:Int, errorLinePosStart:Int, errorLinePosEnd:Int, message:String = null) {
        final codePreviewFull = code.split("\n");
        final previewStart = ErrorHelper.clamp(1, errorLine - 2, errorLine - 2);
        final previewEnd = ErrorHelper.clamp(1, codePreviewFull.length + 1, errorLine + 3) ;

        final codePreview = codePreviewFull.slice(previewStart - 1, previewEnd);
        final minIndentation = getMinIndentation(codePreview);

        final lineCountWidth = Std.string(errorLine + 3).length;

        for (i in previewStart...previewEnd) {
            final lineCount = StringTools.rpad(Std.string(i), " ", lineCountWidth);
            final codeLine = codePreviewFull[i - 1].substring(minIndentation);

            if (i == errorLine) {
                if (errorLinePosEnd == -1) {
                    final highlightPosition = new StringBuf();
                    highlightPosition.add('${ErrorHelper.repeatString(errorLinePosStart - minIndentation, " ")}^ ');
                    if (message != null) {
                        highlightPosition.add(message);
                    }

                    Console.log('   $lineCount | $codeLine');
                    Console.log('   ${ErrorHelper.repeatString(lineCountWidth, " ")} | <#DE4A3F>$highlightPosition</>');
                } else {
                    final literalLength = errorLinePosEnd - errorLinePosStart;

                    final codeLineHighlighted = new StringBuf();
                    codeLineHighlighted.add(codeLine.substring(0, errorLinePosStart - minIndentation));
                    codeLineHighlighted.add("<#DE4A3F>");
                    codeLineHighlighted.add(codeLine.substr(errorLinePosStart - minIndentation, literalLength));
                    codeLineHighlighted.add("</>");
                    codeLineHighlighted.add(codeLine.substr(errorLinePosStart - minIndentation + literalLength, codeLineHighlighted.length));
    
                    Console.log('   $lineCount | ${codeLineHighlighted.toString()}');
    
                    final underline = '${ErrorHelper.repeatString(errorLinePosStart - minIndentation, " ")}${ErrorHelper.repeatString(literalLength, "~")}';
    
                    Console.log('   ${ErrorHelper.repeatString(lineCountWidth, " ")} | <#DE4A3F>$underline</>');
                }
            } else {
                Console.log('   $lineCount | $codeLine');
            }
        } 
    }

    function printHead(line:Int, linePos:Int, message:String) {
        Console.log('<b>${filename}:$line:${linePos + 1}</> <#DE4A3F>error:</> $message.');
    }

    public function unexpectedToken(token:Token, expected:String) {
        final position = ErrorHelper.resolvePosition(code, token.position);
        printHead(position.line, position.linePos, 'unexpected token `${token.literal}` (${token.type})');
        Console.log('Expected $expected.');
        printCode(position.line, position.linePos, position.linePos + token.literal.length);

        Sys.exit(0);
    }

    public function missingSemicolon(token:Token) {
        final position = ErrorHelper.resolvePosition(code, token.position);
        printHead(position.line, position.linePos, "missing semicolon");
        printCode(position.line, position.linePos, position.linePos + token.literal.length);

        Sys.exit(0);
    }

    public function unexpectedEof(token:Token) {
        final position = ErrorHelper.resolvePosition(code, token.position);
        printHead(position.line, position.linePos, 'unexpcted end of file');
        printCode(position.line, position.linePos, position.linePos + token.literal.length);

        Sys.exit(0);
    }
    
    public function illegalToken(token:Token) {
        final position = ErrorHelper.resolvePosition(code, token.position);
        printHead(position.line, position.linePos, 'illegal token `${token.literal}` (${token.type})');
        printCode(position.line, position.linePos, position.linePos + token.literal.length);

        Sys.exit(0);
    }

    public function symbolUndefined(cPosition:Int, symbol:String) {
        final position = ErrorHelper.resolvePosition(code, cPosition);
        printHead(position.line, position.linePos, 'cannot find symbol `$symbol` in this scope');
        printCode(position.line, position.linePos, -1, "not found in this scope");

        Sys.exit(0);
    }

    public function symbolImmutable(cPosition:Int, symbol:String) {
        final position = ErrorHelper.resolvePosition(code, cPosition);
        printHead(position.line, position.linePos, 'cannot re-assign to immutable variable `$symbol`');
        printCode(position.line, position.linePos, -1, "cannot be re-assgined");

        Sys.exit(0);
    }

    public function redeclareVariable(cPosition:Int, symbol:String) {
        final position = ErrorHelper.resolvePosition(code, cPosition);
        printHead(position.line, position.linePos, 'cannot re-declare immutable variable `$symbol`');
        printCode(position.line, position.linePos, -1, "has already been declared in this scope");

        Sys.exit(0);
    }
}