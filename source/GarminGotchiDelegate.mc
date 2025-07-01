using Toybox.WatchUi as ui;
using Toybox.Timer as time;
using Toybox.Lang as std;

using tamalib as tama;

class GarminGotchiDelegate extends ui.BehaviorDelegate {

    const BUTTON_TIMER_PERIOD_MS = 100;
    const BUTTON_FIELD_BITS      = 4;
    const BUTTON_FIELD_MASK      = (1 << BUTTON_FIELD_BITS) - 1;
    const BUTTON_NAME_POS        = 1;
    const BUTTON_NAME_LSB        = (BUTTON_NAME_POS * BUTTON_FIELD_BITS);
    const BUTTON_NAME_MASK       = (BUTTON_FIELD_MASK << BUTTON_NAME_LSB);
    const BUTTON_STATE_POS       = 0;
    const BUTTON_STATE_LSB       = (BUTTON_STATE_POS * BUTTON_FIELD_BITS);
    const BUTTON_STATE_MASK      = (BUTTON_FIELD_MASK << BUTTON_STATE_LSB);

    var game as GarminGotchiApp;
    var button_timer as time.Timer = new time.Timer();

    function initialize(game as GarminGotchiApp) {
        BehaviorDelegate.initialize();
        me.game = game;
        me.button_timer.start(method(:button_timer_callback), BUTTON_TIMER_PERIOD_MS, true);
    }

    function onMenu() as std.Boolean {
        ui.pushView(new Rez.Menus.Menu(), new GarminGotchiMenuDelegate(game), ui.SLIDE_UP);
        return true;
    }

    function onPreviousPage() as std.Boolean {
        add_button_event(tama.BTN_LEFT);
        return true;
    }

    function onNextPage() as std.Boolean {
        add_button_event(tama.BTN_RIGHT);
        return true;
    }

    function onSelect() as std.Boolean {
        add_button_event(tama.BTN_MIDDLE);
        return true;
    }

    function onBack() as std.Boolean {
        add_button_event(tama.BTN_TAP);
        return true;
    }

    function button_timer_callback() as Void {
        if (game.button_events.size() == 0) { return; }

        var event = game.button_events[0];
        var button = decode_button_name(event);
        var state = decode_button_state(event);
        game.button_events.remove(event);

        game.log(tama.LOG_INFO, "Button %s has been %s\n", [
            tama.Button_toString(button),
            tama.ButtonState_toString(state),
        ]);
        game.emulator.set_button(button, state);
    }

    function add_button_event(button as tama.Button) as Void {
        game.button_events.add(encode_button(button, tama.BTN_STATE_PRESSED));
        game.button_events.add(encode_button(button, tama.BTN_STATE_RELEASED));
    }

    function encode_button(button as tama.Button, state as tama.ButtonState) as tama.U8 {
        return ((button << BUTTON_NAME_LSB) | (state << BUTTON_STATE_LSB)) as tama.U8;
    }

    function decode_button_name(byte as tama.U8) as tama.Button {
        return ((byte & BUTTON_NAME_MASK) >> BUTTON_NAME_LSB) as tama.Button;
    }

    function decode_button_state(byte as tama.U8) as tama.ButtonState {
        return ((byte & BUTTON_STATE_MASK) >> BUTTON_STATE_LSB) as tama.ButtonState;
    }

}
