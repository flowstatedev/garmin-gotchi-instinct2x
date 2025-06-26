using Toybox.Application as app;
using Toybox.System as sys;
using Toybox.WatchUi as ui;
using Toybox.Timer as time;
using Toybox.Lang;

using tamalib as tl;

class GarminGotchiApp extends app.AppBase {

    (:silence_log) const LOG_LEVEL_FLAGS = 0;
    (:verbose_log) const LOG_LEVEL_FLAGS = (0
        | tl.LOG_ERROR
        | tl.LOG_INFO
        | tl.LOG_MEMORY
        | tl.LOG_CPU
        | tl.LOG_INT
    );
    (:verbose_log) const RUN_MAX_STEPS = 10;
    (:silence_log) const RUN_MAX_STEPS = 155;
    (:tama_program) const PROGRAM = tama_program;
    (:test_program) const PROGRAM = test_program;
    const RUN_TIMER_PERIOD_MS = 50;
    const SPEED_RATIO = 0;
    const CLOCK_FREQ = 1000000;

    var emulator as tl.Tamalib = new tl.Tamalib_impl() as tl.Tamalib;
    var breakpoints as tl.Breakpoints?;
    var matrix as tl.Bytes = new [tl.LCD_WIDTH * tl.LCD_HEIGHT]b;
    var icons as tl.Bytes = new [tl.ICON_NUM]b;
    var button_events as tl.Bytes = []b;
    var start_time as tl.Timestamp = sys.getTimer();
    var run_timer as time.Timer = new time.Timer();

    function initialize() {
        AppBase.initialize();
        reset();
    }

    function onStart(state as Lang.Dictionary?) as Void {
        start();
    }

    function onStop(state as Lang.Dictionary?) as Void {
        stop();
    }

    function getInitialView() as [ui.Views] or [ui.Views, ui.InputDelegates] {
        return [ new GarminGotchiView(me), new GarminGotchiDelegate(me) ];
    }

    function reset() as Void {
        breakpoints = null;
        for (var i = 0; i < tl.LCD_WIDTH * tl.LCD_HEIGHT; i++) {
            matrix[i] = 0;
        }
        for (var i = 0; i < tl.ICON_NUM; i++) {
            icons[i] = 0;
        }
        while (button_events.size() > 0) {
            button_events.remove(button_events[0]);
        }
        start_time = sys.getTimer();

        emulator.register_hal(me);
        emulator.init(PROGRAM, breakpoints, CLOCK_FREQ);
        emulator.set_speed(SPEED_RATIO);
    }

    function start() as Void {
        emulator.set_exec_mode(tl.EXEC_MODE_RUN);
        run_timer.start(method(:run_timer_callback), RUN_TIMER_PERIOD_MS, true);
    }

    function pause() as Void {
        emulator.set_exec_mode(tl.EXEC_MODE_PAUSE);
        run_timer.stop();
    }

    function stop() as Void {
        pause();
        emulator.release();
        if (breakpoints != null) {
            emulator.free_bp(breakpoints);
        }
    }

    function save() as Void {
        tl.save_state(emulator.get_state());
    }

    function load() as Void {
        tl.load_state(emulator.get_state());
    }

    function run_timer_callback() as Void {
        for (var i = 0; i < RUN_MAX_STEPS; i++) {
            emulator.step();
        }
    }

    /** NOTE: HAL interface API implementations */

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
        return sys.getTimer() - start_time;
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

function getApp() as GarminGotchiApp {
    return app.getApp() as GarminGotchiApp;
}
