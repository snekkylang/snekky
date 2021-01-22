package lexer;

class Position {

    public final position:Int;
    public final line:Int;
    public final lineOffset:Int;

    public function new(position:Int, line:Int, lineOffset:Int) {
        this.position = position;
        this.line = line;
        this.lineOffset = lineOffset;
    }

    function toString():String {
        return '($position, $line, $lineOffset)';    
    }
}