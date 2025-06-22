using Toybox.Graphics as gfx;
using Toybox.WatchUi as ui;
using Toybox.Timer as time;
using Toybox.Lang;

using tamalib as tl;

class GarminGotchiGame {

    class ButtonEvent {
        var button as tl.Button;
        var state as tl.ButtonState;

        function initialize(button as tl.Button, state as tl.ButtonState) {
            me.button = button;
            me.state = state;
        }
    }
    typedef ButtonEvents as Lang.Array<ButtonEvent>;

    (:silence_log) const LOG_LEVEL_FLAGS = 0;
    (:verbose_log) const LOG_LEVEL_FLAGS = (0
        | tl.LOG_ERROR
        | tl.LOG_INFO
        | tl.LOG_MEMORY
        | tl.LOG_CPU
        | tl.LOG_INT
    );
    const RUN_TIMER_PERIOD_MS = 50;
    const DRAW_TIMER_PERIOD_MS = 500;
    const BUTTON_TIMER_PERIOD_MS = 100;
    const SPEED_RATIO = 0;
    const CLOCK_FREQ = 1000000;
    (:verbose_log) const RUN_MAX_STEPS = 10;
    (:silence_log) const RUN_MAX_STEPS = 150;
    (:tama_program) const PROGRAM as tl.Program = tama_program;
    (:test_program) const PROGRAM as tl.Program = test_program;

    var graphics as GarminGotchiGraphics = new GarminGotchiGraphics();
    var emulator as tl.Tamalib = new tl.Tamalib_impl() as tl.Tamalib;
    var start_time as tl.Int = System.getTimer();
    var run_timer as time.Timer = new time.Timer();
    var draw_timer as time.Timer = new time.Timer();
    var button_timer as time.Timer = new time.Timer();
    var breakpoints as tl.Breakpoints? = null;
    var matrix as tl.Bytes = new [tl.LCD_WIDTH * tl.LCD_HEIGHT]b;
    var icons as tl.Bytes = new [tl.ICON_NUM]b;
    var button_events as ButtonEvents = [];

    function init() as Void {
        emulator.register_hal(me);
        emulator.init(PROGRAM, breakpoints, CLOCK_FREQ);
        emulator.set_speed(SPEED_RATIO);
        emulator.set_exec_mode(tl.EXEC_MODE_RUN);
    }

    function start() as Void {
        run_timer.start(method(:run_max_steps), RUN_TIMER_PERIOD_MS, true);
        draw_timer.start(method(:update_screen), DRAW_TIMER_PERIOD_MS, true);
        button_timer.start(method(:process_button_event), BUTTON_TIMER_PERIOD_MS, true);
    }

    function stop() as Void {
        run_timer.stop();
        draw_timer.stop();
        emulator.release();
        if (breakpoints != null) {
            emulator.free_bp(breakpoints);
        }
    }

    function compute_layout(dc as gfx.Dc) as Void {
        graphics.init(dc, matrix, icons);
    }

    function draw(dc as gfx.Dc) as Void {
        graphics.draw(dc);
    }

    function press_left() as Void {
        add_button_event(tl.BTN_LEFT);
    }

    function press_middle() as Void {
        add_button_event(tl.BTN_MIDDLE);
    }

    function press_right() as Void {
        add_button_event(tl.BTN_RIGHT);
    }

    function press_tap() as Void {
        add_button_event(tl.BTN_TAP);
    }

    function add_button_event(button as tl.Button) as Void {
        button_events.addAll([
            new ButtonEvent(button, tl.BTN_STATE_PRESSED),
            new ButtonEvent(button, tl.BTN_STATE_RELEASED),
        ]);
    }

    function process_button_event() as Void {
        if (button_events.size() > 0) {
            var event = button_events[0];
            emulator.set_button(event.button, event.state);
            button_events.remove(event);
        }
    }

    function run_max_steps() as Void {
        for (var i = 0; i < RUN_MAX_STEPS; i++) {
            emulator.step();
        }
    }

    /** NOTE: HAL function implementations */

    function malloc(size as tl.U32) as tl.Object? { return null; }

    function free(ptr as tl.Object?) as Void {}

    function halt() as Void {}

    function is_log_enabled(level as tl.LogLevel) as tl.Bool {
        return tl.bool(LOG_LEVEL_FLAGS & (level as tl.Int));
    }

    function log(level as tl.LogLevel, buff as tl.String, args as tl.Objects) as Void {
        if (is_log_enabled(level)) {
            tl.printf(buff, args);
        }
    }

    function sleep_until(ts as tl.Timestamp) as Void {
        var t0 = get_timestamp();
        while (get_timestamp() - t0 < ts) {}
    }

    function get_timestamp() as tl.Timestamp {
        return System.getTimer() - start_time;
    }

    function update_screen() as Void {
        ui.requestUpdate();
    }

    function set_lcd_matrix(x as tl.U8, y as tl.U8, val as tl.Bool) as Void {
        matrix[x + y * tl.LCD_WIDTH] = tl.int(val);
    }

    function set_lcd_icon(icon as tl.U8, val as tl.Bool) as Void {
        icons[icon] = tl.int(val);
    }

    function set_frequency(freq as tl.U32) as Void {
        /* TODO */
    }

    function play_frequency(en as tl.Bool) as Void {
        /* TODO */
    }

    function handler() as tl.Int {
        return 0;
    }

}
