package object.objects;

import error.ErrorHelper;
import compiler.symbol.Symbol;

class FunctionObj extends Object {

    public final bytePosition:Int;
    public final name:String;
    public final line:Int;
    public final linePos:Int;
    public final filename = Snekky.filename;

    public function new(bytePosition:Int, symbol:Symbol) {
        super(ObjectType.Function);
        
        this.bytePosition = bytePosition;
        
        name = symbol.name;
        final cPosition = ErrorHelper.resolvePosition(symbol.position);
        line = cPosition.line;
        linePos = cPosition.linePos;
    }
}