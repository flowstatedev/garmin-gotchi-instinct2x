using Toybox.Application as app;
using Toybox.Attention as att;
using Toybox.System as sys;
using Toybox.WatchUi as ui;
using Toybox.Timer as time;
using Toybox.Lang as std;

using tamalib as tama;

class GarminGotchiApp extends app.AppBase {

    (:enable_sounds) const HAS_TONE_PROFILE as tama.Bool = att has :ToneProfile;
    (:enable_sounds) typedef ToneProfile as {
        :toneProfile as $.Toybox.Lang.Array<$.Toybox.Attention.ToneProfile>,
        :repeatCount as $.Toybox.Lang.Number,
    };

    (:silence_log) const LOG_LEVEL_FLAGS = 0;
    (:verbose_log) const LOG_LEVEL_FLAGS = (0
        | tama.LOG_ERROR
        | tama.LOG_INFO
        | tama.LOG_MEMORY
        | tama.LOG_CPU
        | tama.LOG_INT
    );

    (:verbose_log) const RUN_MAX_STEPS       = 10;
    (:silence_log) const RUN_MAX_STEPS       = 155;
                   const RUN_TIMER_PERIOD_MS = 50;

    (:tama_program) const PROGRAM = TAMA_PROGRAM;
    (:test_program) const PROGRAM = TEST_PROGRAM;

    const SPEED_RATIO       = 0;
    const CLOCK_FREQ        = 1000000;
    const SOUND_DURATION_MS = 250;

    var emulator as tama.Tamalib = new tama.Tamalib_impl() as tama.Tamalib;
    var breakpoints as tama.Breakpoints? = null;
    var matrix as tama.Bytes = new [tama.LCD_WIDTH * tama.LCD_HEIGHT]b;
    var icons as tama.Bytes = new [tama.ICON_NUM]b;
    var button_events as tama.Bytes = []b;

    (:enable_sounds) var sound_profile as ToneProfile? = null;
    (:enable_sounds) var is_sound_enabled as tama.Bool = true;

    var start_time as tama.Timestamp = sys.getTimer();
    var run_timer as time.Timer = new time.Timer();

    function initialize() {
        AppBase.initialize();
        load();
    }

    function onStart(state as std.Dictionary?) as Void {
        start();
    }

    function onStop(state as std.Dictionary?) as Void {
        stop();
    }

    function getInitialView() as [ui.Views] or [ui.Views, ui.InputDelegates] {
        return [ new GarminGotchiView(me), new GarminGotchiDelegate(me) ];
    }

    function reset() as Void {
        breakpoints = null;
        for (var i = 0; i < tama.LCD_WIDTH * tama.LCD_HEIGHT; i++) {
            matrix[i] = 0;
        }
        for (var i = 0; i < tama.ICON_NUM; i++) {
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
        emulator.set_exec_mode(tama.EXEC_MODE_RUN);
        run_timer.start(method(:run_timer_callback), RUN_TIMER_PERIOD_MS, true);
    }

    function pause() as Void {
        emulator.set_exec_mode(tama.EXEC_MODE_PAUSE);
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
        tama.save_state(emulator.get_state());
    }

    function load() as Void {
        reset();
        tama.load_state(emulator.get_state());
    }

    (:disable_sounds) function sound_toggle() as Void {}
    (:enable_sounds)  function sound_toggle() as Void {
        is_sound_enabled = !is_sound_enabled;
    }

    (:disable_sounds) function is_sound_playable(en as tama.Bool) as tama.Bool { return false; }
    (:enable_sounds)  function is_sound_playable(en as tama.Bool) as tama.Bool {
        return (en) && (is_sound_enabled) && (HAS_TONE_PROFILE) && (sound_profile != null);
    }

    function run_timer_callback() as Void {
        for (var i = 0; i < RUN_MAX_STEPS; i++) {
            emulator.step();
        }
    }

    /** NOTE: HAL interface API implementations */

    function malloc(size as tama.U32) as tama.Object? { return null; }

    function free(ptr as tama.Object?) as Void {}

    function halt() as Void {}

    (:silence_log) function is_log_enabled(level as tama.LogLevel) as tama.Bool { return false; }
    (:verbose_log) function is_log_enabled(level as tama.LogLevel) as tama.Bool {
        return tama.bool(LOG_LEVEL_FLAGS & (level as tama.Int));
    }

    (:silence_log) function log(level as tama.LogLevel, buff as tama.String, args as tama.Objects) as Void {}
    (:verbose_log) function log(level as tama.LogLevel, buff as tama.String, args as tama.Objects) as Void {
        if (is_log_enabled(level)) {
            tama.printf(buff, args);
        }
    }

    function sleep_until(ts as tama.Timestamp) as Void {
        var t0 = get_timestamp();
        while (get_timestamp() - t0 < ts) {}
    }

    function get_timestamp() as tama.Timestamp {
        return sys.getTimer() - start_time;
    }

    function update_screen() as Void {
        ui.requestUpdate();
    }

    function set_lcd_matrix(x as tama.U8, y as tama.U8, val as tama.Bool) as Void {
        matrix[x + y * tama.LCD_WIDTH] = tama.int(val);
    }

    function set_lcd_icon(icon as tama.U8, val as tama.Bool) as Void {
        icons[icon] = tama.int(val);
    }

    (:disable_sounds) function set_frequency(freq as tama.U32) as Void {}
    (:enable_sounds)  function set_frequency(freq as tama.U32) as Void {
        if (HAS_TONE_PROFILE) {
            sound_profile = {
                :toneProfile => [new att.ToneProfile(freq / 10, SOUND_DURATION_MS)],
                :repeatCount => 1,
            };
        }
    }

    (:disable_sounds) function play_frequency(en as tama.Bool) as Void {}
    (:enable_sounds)  function play_frequency(en as tama.Bool) as Void {
        if (is_sound_playable(en)) {
            att.playTone(sound_profile as ToneProfile);
        }
    }

    function handler() as tama.Int {
        return 0;
    }

}

function getApp() as GarminGotchiApp {
    return app.getApp() as GarminGotchiApp;
}
