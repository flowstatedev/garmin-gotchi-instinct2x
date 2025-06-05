import Toybox.Lang;

module tamalib {

class HAL_impl {

    function malloc(size as U32) as Object? {
        /* TODO */
        return null;
    }

    function free(ptr as Object?) as Void {
        /* TODO */
    }

    function halt() as Void {
        /* TODO */
    }

    function is_log_enabled(level as LogLevel) as Bool {
        /* TODO */
        return false;
    }

    function log(level as LogLevel, buff as String, args as Array) as Void {
        /* TODO */
    }

    function sleep_until(ts as Timestamp) as Void {
        /* TODO */
    }

    function get_timestamp() as Timestamp {
        /* TODO */
        return 0;
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
