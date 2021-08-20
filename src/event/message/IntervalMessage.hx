package event.message;

import event.message.Message.MessageType;
import object.ClosureObj;

class IntervalMessage extends Message {

    public final interval:Int;
    var lastExecuted = getCurrentMsTime();
    public var cleared(default, null) = false;

    public function new(handler:ClosureObj, interval:Int) {
        super(MessageType.Interval, handler, null);

        this.interval = interval;
    }

    public function shouldExecute():Bool {
        if (getCurrentMsTime() - lastExecuted >= interval) {
            lastExecuted = getCurrentMsTime();
            return true;
        }

        return false;
    }

    public function clear() {
        cleared = true;
    }

    static function getCurrentMsTime():Int {
        return Std.int(Sys.time() * 1000);
    }
}