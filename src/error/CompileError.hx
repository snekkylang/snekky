package error;

import lexer.Position;
import lexer.Helper;
import lexer.Token;

class CompileError {

    static var init = {
        Console.logPrefix = "";
    }

    public var filename:String;
    public var code:String;

    public function new(filename:String, code:String) {
        this.filename = filename;
        this.code = code;
    }

    function getMinIndentation(code:Array<String>):Int {
        var min = 2147483647;

        for (line in code) {
            if (line.length == 0 || Helper.isLinebreak(line.charAt(0))) {
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

    function printCode(position:Position, errorLinePosEnd:Int, message:String = null) {
        final codePreviewFull = code.split("\n");
        final previewStart = ErrorHelper.clamp(1, position.line - 2, position.line - 2);
        final previewEnd = ErrorHelper.clamp(1, codePreviewFull.length + 1, position.line + 3) ;

        final codePreview = codePreviewFull.slice(previewStart - 1, previewEnd);
        final minIndentation = getMinIndentation(codePreview);

        final lineCountWidth = Std.string(position.line + 3).length;

        for (i in previewStart...previewEnd) {
            final lineCount = StringTools.rpad(Std.string(i), " ", lineCountWidth);
            final codeLine = codePreviewFull[i - 1].substring(minIndentation);

            if (i == position.line) {
                if (errorLinePosEnd == -1) {
                    final highlightPosition = new StringBuf();
                    highlightPosition.add('${ErrorHelper.repeatString(position.lineOffset - minIndentation, " ")}^ ');
                    if (message != null) {
                        highlightPosition.add(message);
                    }

                    Console.log('   $lineCount | $codeLine');
                    Console.log('   ${ErrorHelper.repeatString(lineCountWidth, " ")} | <#DE4A3F>$highlightPosition</>');
                } else {
                    final literalLength = errorLinePosEnd - position.lineOffset;

                    final codeLineHighlighted = new StringBuf();
                    codeLineHighlighted.add(codeLine.substring(0, position.lineOffset - minIndentation));
                    codeLineHighlighted.add("<#DE4A3F>");
                    codeLineHighlighted.add(codeLine.substr(position.lineOffset - minIndentation, literalLength));
                    codeLineHighlighted.add("</>");
                    codeLineHighlighted.add(codeLine.substr(position.lineOffset - minIndentation + literalLength));
    
                    Console.log('   $lineCount | ${codeLineHighlighted.toString()}');
    
                    final underline = '${ErrorHelper.repeatString(position.lineOffset - minIndentation, " ")}${ErrorHelper.repeatString(literalLength, "~")}';
    
                    Console.log('   ${ErrorHelper.repeatString(lineCountWidth, " ")} | <#DE4A3F>$underline</>');
                }
            } else {
                Console.log('   $lineCount | $codeLine');
            }
        } 
    }

    function printErrorHead(position:Position, message:String) {
        Console.log('<b>${filename}:${position.line}:${position.lineOffset + 1}</> <#DE4A3F>error:</> $message');
    }

    function printWarnHead(position:Position, message:String) {
        Console.log('<b>${filename}:${position.line}:${position.lineOffset + 1}</> <#F39C11>warning:</> $message');
    }

    public function unexpectedToken(token:Token, expected:String) {
        printErrorHead(token.position, 'unexpected token `${token.literal}` (${token.type})');
        Console.log('Expected $expected.');
        printCode(token.position, token.position.lineOffset + token.literal.length);

        ErrorHelper.exit();
    }

    public function missingSemicolon(token:Token) {
        printErrorHead(token.position, "missing semicolon");
        printCode(token.position, token.position.lineOffset + token.literal.length);

        ErrorHelper.exit();
    }

    public function unexpectedEof(token:Token) {
        printErrorHead(token.position, 'unexpcted end of file');
        printCode(token.position, token.position.lineOffset + token.literal.length);

        ErrorHelper.exit();
    }
    
    public function illegalToken(token:Token) {
        printErrorHead(token.position, 'illegal token `${token.literal}` (${token.type})');
        printCode(token.position, token.position.lineOffset + token.literal.length);

        ErrorHelper.exit();
    }

    public function importFailed(token:Token, fileName:String) {
        printErrorHead(token.position, 'failed to import file `$filename`');
        printCode(token.position, token.position.lineOffset + token.literal.length);

        ErrorHelper.exit();
    }

    public function illegalContinue(position:Position) {
        printErrorHead(position, 'illegal continue statement');
        printCode(position, -1, "may only be used inside loops");

        ErrorHelper.exit();
    }
    
    public function illegalBreak(position:Position) {
        printErrorHead(position, 'illegal break statement');
        printCode(position, -1, "may only be used inside loops");

        ErrorHelper.exit();
    }

    public function illegalReturn(position:Position) {
        printErrorHead(position, 'illegal return statement');
        printCode(position, -1, "may only be used inside functions");

        ErrorHelper.exit();
    }

    public function symbolUndefined(position:Position, symbol:String) {
        printErrorHead(position, 'cannot find symbol `$symbol` in this scope');
        printCode(position, -1, "not found in this scope");

        ErrorHelper.exit();
    }

    public function symbolImmutable(position:Position, symbol:String) {
        printErrorHead(position, 'cannot re-assign to immutable variable `$symbol`');
        printCode(position, -1, "cannot be re-assgined");

        ErrorHelper.exit();
    }

    public function redeclareVariable(position:Position, symbol:String) {
        printErrorHead(position, 'cannot re-declare immutable variable `$symbol`');
        printCode(position, -1, "has already been declared in this scope");

        ErrorHelper.exit();
    }

    public function dollarVariableName(position:Position, symbol:String) {
        printWarnHead(position, 'symbol name `$symbol` contains $ which be used only in mechanically generated code');
    }
}