package event.message;

interface Timable {

    function shouldExecute():Bool;
    function clear():Void;
    var cleared(default, null):Bool;
}