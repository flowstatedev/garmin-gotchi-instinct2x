using Toybox.Application as app;
using Toybox.Attention as att;
using Toybox.System as sys;
using Toybox.WatchUi as ui;
using Toybox.Timer as time;
import Toybox.Lang;

using tamalib as tama;

class GarminGotchiApp extends app.AppBase {

    (:enable_sounds) const HAS_TONE_PROFILE as tama.Bool = att has :ToneProfile;
    (:enable_sounds) typedef ToneProfile as Array<att.ToneProfile>;
    (:enable_sounds) typedef SoundProfile as {:toneProfile as ToneProfile, :repeatCount as Number};

    (:enable_log) const LOG_LEVEL_FLAGS = (0
        | tama.LOG_ERROR
        | tama.LOG_INFO
        | tama.LOG_MEMORY
        | tama.LOG_CPU
        | tama.LOG_INT
    );

    (:enable_log)  const RUN_MAX_STEPS = 10;
    // (:disable_log) const RUN_MAX_STEPS = 160; // instinct3solar45mm
    (:disable_log) const RUN_MAX_STEPS = 40; // instinct2x
    const RUN_TIMER_PERIOD_MS     = 50;
    const UPDATE_SCREEN_PERIOD_MS = 500;
    const UPDATE_SCREEN_THRESHOLD = (UPDATE_SCREEN_PERIOD_MS / RUN_TIMER_PERIOD_MS);

    // (:tama_program) const PROGRAM = TAMA_PROGRAM;
    // (:test_program) const PROGRAM = TEST_PROGRAM;

    const PROGRAM as ByteArray = new [12288]b;
    const PROGRAM_FRAGMENT_SIZE = 3072; // size of each fragment in bytes

    const SPEED_RATIO       = 0;
    const CLOCK_FREQ        = 1000000;
    const SOUND_DURATION_MS = 250;

    // var view as GarminGotchiView     = new GarminGotchiView(me);
    // var ctrl as GarminGotchiDelegate = new GarminGotchiDelegate(me);
    var ctrl as GarminGotchiDelegate?;

    var emulator as tama.Tamalib = new tama.Tamalib_impl() as tama.Tamalib;
    var breakpoints as tama.Breakpoints? = null;
    var matrix as tama.Bytes = new [tama.LCD_WIDTH * tama.LCD_HEIGHT]b;
    var icons as tama.Bytes = new [tama.ICON_NUM]b;

    var update_screen_counter as tama.Int = 0;
    var update_screen_request as tama.Bool = true;

    (:enable_sounds) var is_sound_enabled as tama.Bool = true;
    (:enable_sounds) var sound_profile as SoundProfile = {
        :toneProfile => [new att.ToneProfile(0, SOUND_DURATION_MS)],
        :repeatCount => 1,
    };

    var start_time as tama.Timestamp = sys.getTimer();
    var run_timer as time.Timer = new time.Timer();

    function loadProgramFragment(rezId as Symbol, offset as Number) as Void {
        var fragment = Application.loadResource(Rez.JsonData[rezId] as ResourceId) as Array<Number>;
        // The program fragment is stored in an Array of Numbers (in JSON), where each Number encodes
        // 4 bytes from the original program data
        var fragment_array_size = PROGRAM_FRAGMENT_SIZE / 4;
        if (fragment_array_size != fragment.size()) {
            throw new InvalidValueException("Program fragment from JSON has actual array size of " + fragment.size() + "; expected array size is " + fragment_array_size);
        }
        for (var i = 0; i < fragment_array_size; i++) {
            var v = fragment[i];
            PROGRAM[offset] = v >> 24;
            offset++;
            PROGRAM[offset] = (v >> 16) & 0xff;
            offset++;
            PROGRAM[offset] = (v >> 8) & 0xff;
            offset++;
            PROGRAM[offset] = (v) & 0xff;
            offset++;
        }
    }

    function initialize() {
        AppBase.initialize();

        loadProgramFragment(:TAMA_PROGRAM1, 0);
        loadProgramFragment(:TAMA_PROGRAM2, PROGRAM_FRAGMENT_SIZE);

        run_timer.start(method(:afterLoadHalfProgram), 50, false);
    }

    function afterLoadHalfProgram() as Void {
        loadProgramFragment(:TAMA_PROGRAM3, PROGRAM_FRAGMENT_SIZE * 2);
        loadProgramFragment(:TAMA_PROGRAM4, PROGRAM_FRAGMENT_SIZE * 3);

        run_timer.start(method(:afterLoadFullProgram), 50, false);
    }

    var isProgramLoaded as Boolean = false;
    function afterLoadFullProgram() as Void {
        load();
        isProgramLoaded = true;
        onStart(null);
    }

    function onStart(state as Dictionary?) as Void {
        if (isProgramLoaded) {
            start();
        }
    }

    function onStop(state as Dictionary?) as Void {
        stop();
    }

    function getInitialView() as [ui.Views] or [ui.Views, ui.InputDelegates] {
        ctrl = new GarminGotchiDelegate(me);
        return [new GarminGotchiView(me), ctrl];
    }

    function reset() as Void {
        breakpoints = null;
        for (var i = 0; i < tama.LCD_WIDTH * tama.LCD_HEIGHT; i++) {
            matrix[i] = 0;
        }
        for (var i = 0; i < tama.ICON_NUM; i++) {
            icons[i] = 0;
        }
        start_time = sys.getTimer();

        if (ctrl != null) {
            ctrl.clear_button_events();
        }

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
        return (en) && (is_sound_enabled) && (HAS_TONE_PROFILE);
    }

    function run_timer_callback() as Void {
        handler();

        for (var i = 0; i < RUN_MAX_STEPS; i++) {
            emulator.step();
        }

        update_screen_counter++;
        if (update_screen_counter >= UPDATE_SCREEN_THRESHOLD) {
            update_screen_counter = 0;
            update_screen();
        }
    }

    /** NOTE: HAL interface API implementations */

    function malloc(size as tama.U32) as tama.Object? { return null; }

    function free(ptr as tama.Object?) as Void {}

    function halt() as Void {}

    (:disable_log) function is_log_enabled(level as tama.LogLevel) as tama.Bool { return false; }
    (:enable_log)  function is_log_enabled(level as tama.LogLevel) as tama.Bool {
        return (LOG_LEVEL_FLAGS & (level as tama.Int)) ? true : false;
    }

    (:disable_log) function log(level as tama.LogLevel, buff as tama.String, args as tama.Objects) as Void {}
    (:enable_log)  function log(level as tama.LogLevel, buff as tama.String, args as tama.Objects) as Void {
        if (is_log_enabled(level)) {
            tama.printf(buff, args);
        }
    }

    (:disable_sleep) function sleep_until(ts as tama.Timestamp) as Void {}
    (:enable_sleep)  function sleep_until(ts as tama.Timestamp) as Void {
        var t0 = get_timestamp();
        while (get_timestamp() - t0 < ts) {}
    }

    function get_timestamp() as tama.Timestamp {
        return sys.getTimer() - start_time;
    }

    function update_screen() as Void {
        if (update_screen_request) {
            update_screen_request = false;
            ui.requestUpdate();
        }
    }

    function set_lcd_matrix(x as tama.U8, y as tama.U8, val as tama.Bool) as Void {
        var old_val = matrix[x + y * tama.LCD_WIDTH];
        var new_val = val ? 1 : 0;
        if (old_val != new_val) {
            update_screen_request = true;
            matrix[x + y * tama.LCD_WIDTH] = new_val;
        }
    }

    function set_lcd_icon(icon as tama.U8, val as tama.Bool) as Void {
        var old_val = icons[icon];
        var new_val = val ? 1 : 0;
        if (old_val != new_val) {
            update_screen_request = true;
            icons[icon] = new_val;
        }
    }

    (:disable_sounds) function set_frequency(freq as tama.U32) as Void {}
    (:enable_sounds)  function set_frequency(freq as tama.U32) as Void {
        if (HAS_TONE_PROFILE) {
            var tone = (sound_profile[:toneProfile] as ToneProfile)[0];
            tone.frequency = freq / 10;
        }
    }

    (:disable_sounds) function play_frequency(en as tama.Bool) as Void {}
    (:enable_sounds)  function play_frequency(en as tama.Bool) as Void {
        if (is_sound_playable(en)) {
            att.playTone(sound_profile);
        }
    }

    function handler() as tama.Int {
        if (ctrl != null) {
            ctrl.handle_button_events();
        }
        return 0;
    }

}

// function getApp() as GarminGotchiApp {
//     return app.getApp() as GarminGotchiApp;
// }
