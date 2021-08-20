package event.message;

import event.message.Message.MessageType;
import object.ClosureObj;

class TimeoutMessage extends Message {

    public final timeout:Int;
    public var cleared(default, null) = false;

    public function new(handler:ClosureObj, timeout:Int) {
        super(MessageType.Timeout, handler, null);

        this.timeout = getCurrentMsTime() + timeout;
    }

    public function shouldExecute():Bool {
        if (getCurrentMsTime() >= timeout) {
            cleared = true;
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