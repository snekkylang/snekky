package event.message;

import haxe.Timer;
import object.ClosureObj;

class IntervalMessage extends Message implements Timable {

    public final interval:Int;
    var lastExecuted = getCurrentMsStamp();
    public var cleared(default, null) = false;
    public final handler:ClosureObj;

    public function new(handler:ClosureObj, interval:Int) {
        super(null);
        
        this.handler = handler;
        this.interval = interval;
    }

    public function shouldExecute():Bool {
        if (getCurrentMsStamp() - lastExecuted >= interval) {
            lastExecuted = getCurrentMsStamp();
            return true;
        }

        return false;
    }

    public function clear() {
        cleared = true;
    }

    static function getCurrentMsStamp():Int {
        return Std.int(Timer.stamp() * 1000);
    }
}