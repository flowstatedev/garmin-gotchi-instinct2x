import Toybox.Lang;

module tamalib {

class HAL_impl {
    var _start_time as Number;
    var _log_level_flags as Number;

    function initialize(log_level_flags as Number) {
        _start_time = System.getTimer();
        _log_level_flags = log_level_flags;
    }

    function malloc(size as U32) as Object? { return null; }

    function free(ptr as Object?) as Void {}

    function halt() as Void {}

    function is_log_enabled(level as LogLevel) as Bool {
        return bool(_log_level_flags & level);
    }

    function log(level as LogLevel, buff as String, args as Array) as Void {
        if (is_log_enabled(level)) {
            printf(buff, args);
        }
    }

    function sleep_until(ts as Timestamp) as Void {
        // TODO: figure out timing and avoid unnecessary waits
        var t0 = get_timestamp();
        while (get_timestamp() - t0 < ts) {}
    }

    function get_timestamp() as Timestamp {
        return System.getTimer() - _start_time;
    }

    function update_screen() as Void {
        /* TODO */
    }

    function set_lcd_matrix(x as U8, y as U8, val as Bool) as Void {
        /* TODO */
    }

    function set_lcd_icon(icon as U8, val as Bool) as Void {
        /* TODO */
    }

    function set_frequency(freq as U32) as Void {
        /* TODO */
    }

    function play_frequency(en as Bool) as Void {
        /* TODO */
    }

    function handler() as Int {
        /* TODO */
        return 0;
    }

}

}
