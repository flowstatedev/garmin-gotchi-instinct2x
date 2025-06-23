using Toybox.WatchUi as ui;
using Toybox.Timer as time;
using Toybox.Lang;

using tamalib as tl;

class GarminGotchiDelegate extends ui.BehaviorDelegate {

    const BUTTON_TIMER_PERIOD_MS = 100;

    var game as GarminGotchiApp;
    var button_timer as time.Timer = new time.Timer();
    var button_events as tl.Bytes = []b;

    function initialize(game as GarminGotchiApp) {
        BehaviorDelegate.initialize();
        me.game = game;
        me.button_timer.start(method(:button_timer_callback), BUTTON_TIMER_PERIOD_MS, true);
    }

    function onMenu() as Lang.Boolean {
        /** TODO: add logic for saving/resuming game */
        ui.pushView(new Rez.Menus.Menu(), new GarminGotchiMenuDelegate(), ui.SLIDE_UP);
        return true;
    }

    function onPreviousPage() as Lang.Boolean {
        add_button_event(tl.BTN_LEFT);
        return true;
    }

    function onNextPage() as Lang.Boolean {
        add_button_event(tl.BTN_RIGHT);
        return true;
    }

    function onSelect() as Lang.Boolean {
        add_button_event(tl.BTN_MIDDLE);
        return true;
    }

    function onBack() as Lang.Boolean {
        add_button_event(tl.BTN_TAP);
        return true;
    }

    function button_timer_callback() as Void {
        if (button_events.size() == 0) { return; }

        var event = button_events[0];
        var button = decode_button_name(event);
        var state = decode_button_state(event);
        button_events.remove(event);

        game.log(tl.LOG_INFO, "Button %s has been %s\n", [
            tl.Button_toString(button),
            tl.ButtonState_toString(state),
        ]);
        game.emulator.set_button(button, state);
    }

    function add_button_event(button as tl.Button) as Void {
        button_events.add(encode_button(button, tl.BTN_STATE_PRESSED));
        button_events.add(encode_button(button, tl.BTN_STATE_RELEASED));
    }

    function encode_button(button as tl.Button, state as tl.ButtonState) as tl.U8 {
        return ((button << 4) | state);
    }

    function decode_button_name(byte as tl.U8) as tl.Button {
        return ((byte & 0xF0) >> 4) as tl.Button;
    }

    function decode_button_state(byte as tl.U8) as tl.ButtonState {
        return (byte & 0x0F) as tl.ButtonState;
    }

}
