package event.message;

import object.ClosureObj;

interface Timable {

    function shouldExecute():Bool;
    function clear():Void;
    var cleared(default, null):Bool;
    final handler:ClosureObj;
}