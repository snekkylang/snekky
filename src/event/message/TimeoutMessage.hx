package event.message;

import haxe.Timer;
import object.ClosureObj;

class TimeoutMessage extends Message implements Timable {

    public final timeout:Int;
    public var cleared(default, null) = false;

    public function new(handler:ClosureObj, timeout:Int) {
        super(handler, null);

        this.timeout = getCurrentMsStamp() + timeout;
    }

    public function shouldExecute():Bool {
        if (getCurrentMsStamp() >= timeout) {
            cleared = true;
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