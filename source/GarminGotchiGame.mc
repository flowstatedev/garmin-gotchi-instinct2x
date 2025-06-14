using Toybox.Graphics as gfx;
using Toybox.WatchUi as ui;
using Toybox.Timer as time;

using tamalib as tl;

class GarminGotchiGame {

    (:silence_log) const LOG_LEVEL_FLAGS = 0;
    (:verbose_log) const LOG_LEVEL_FLAGS = (
        tl.LOG_ERROR
        | tl.LOG_INFO
        | tl.LOG_MEMORY
        | tl.LOG_CPU
        | tl.LOG_INT
    );

    const RUN_TIMER_MS = 50;
    const DRAW_TIMER_MS = 500;

    const SPEED_RATIO = 0;
    const CLOCK_FREQ = 1000000;

    (:verbose_log) const RUN_MAX_STEPS = 10;
    (:silence_log) const RUN_MAX_STEPS = 150;

    (:standard_colors) const FOREGROUND_COLOR  = gfx.COLOR_WHITE;
    (:inverted_colors) const FOREGROUND_COLOR  = gfx.COLOR_BLACK;
    (:standard_colors) const BACKGROUND_COLOR  = gfx.COLOR_BLACK;
    (:inverted_colors) const BACKGROUND_COLOR  = gfx.COLOR_WHITE;
                       const TRANSPARENT_COLOR = gfx.COLOR_TRANSPARENT;

    (:initialized) var SCREEN as tl.Rect;
    (:initialized) var SUBSCREEN as tl.Circle;
    (:initialized) var MATRIX as tl.Rect;
    (:initialized) var PIXEL_SIZE as tl.Int;
    (:initialized) var BANNER_TOP as tl.Rect;
    (:initialized) var BANNER_BOTTOM as tl.Rect;

    var emulator as tl.Tamalib = new tl.Tamalib_impl() as tl.Tamalib;
    var start_time as tl.Int = System.getTimer();
    var run_timer as time.Timer = new time.Timer();
    var draw_timer as time.Timer = new time.Timer();
    var breakpoints as tl.Breakpoints? = null;

    (:tama_program) var program as tl.Program = tama_program;
    (:test_program) var program as tl.Program = test_program;

    var matrix as tl.Bytes = new [tl.LCD_WIDTH * tl.LCD_HEIGHT]b;
    (:initialized) var pixel as tl.Rect;

    function init() as Void {
        emulator.register_hal(me);
        emulator.init(program, breakpoints, CLOCK_FREQ);
        emulator.set_speed(SPEED_RATIO);
    }

    function start() as Void {
        run_timer.start(method(:run_max_steps), RUN_TIMER_MS, true);
        draw_timer.start(method(:update_screen), DRAW_TIMER_MS, true);
    }

    function draw(dc as gfx.Dc) as Void {
        clear_screen(dc);
        draw_matrix(dc);
        draw_layout(dc);
    }

    function stop() as Void {
        run_timer.stop();
        draw_timer.stop();
        emulator.release();
        if (breakpoints != null) {
            emulator.free_bp(breakpoints);
        }
    }

    function run_max_steps() as Void {
        for (var i = 0; i < RUN_MAX_STEPS; i++) {
            emulator.step();
        }
    }

    function compute_layout(dc as gfx.Dc) as Void {
        SCREEN = new tl.Rect(0, 0, dc.getWidth(), dc.getHeight());
        SUBSCREEN = tl.bbox_to_circle(ui.getSubscreen() as gfx.BoundingBox);

        var screen_w = tl.float(SCREEN.width);
        var screen_h = tl.float(SCREEN.height);
        var pixel_size = tl.min(screen_w / tl.LCD_WIDTH, screen_w / tl.LCD_HEIGHT) as tl.Float;
        var matrix_w = tl.min(screen_w, tl.LCD_WIDTH * pixel_size) as tl.Float;
        var matrix_h = tl.min(screen_w, tl.LCD_HEIGHT * pixel_size) as tl.Float;
        var matrix_x = (screen_w - matrix_w) / 2;
        var matrix_y = (screen_h - matrix_h) / 2;

        PIXEL_SIZE = tl.round(pixel_size);
        pixel = new tl.Rect(0, 0, PIXEL_SIZE, PIXEL_SIZE);
        MATRIX = new tl.Rect(tl.round(matrix_x), tl.round(matrix_y), tl.round(matrix_w), tl.round(matrix_h));
        BANNER_TOP = new tl.Rect(MATRIX.x, 0, MATRIX.width, MATRIX.y);
        BANNER_BOTTOM = new tl.Rect(MATRIX.x, MATRIX.y + MATRIX.height, MATRIX.width, MATRIX.y);
    }

    function clear_screen(dc as gfx.Dc) as Void {
        dc.setColor(FOREGROUND_COLOR, BACKGROUND_COLOR);
        dc.clear();
    }

    function draw_matrix(dc as gfx.Dc) as Void {
        for (var x = 0; x < tl.LCD_WIDTH; x++) {
            for (var y = 0; y < tl.LCD_HEIGHT; y++) {
                if (tl.bool(matrix[x + y * tl.LCD_WIDTH])) {
                    draw_pixel(dc, x, y, FOREGROUND_COLOR, true);
                }
            }
        }
    }

    function draw_pixel(dc as gfx.Dc, x as tl.Int, y as tl.Int, color as gfx.ColorValue, fill as tl.Bool) as Void {
        pixel.x = MATRIX.x + (x * pixel.width);
        pixel.y = MATRIX.y + (y * pixel.height);
        draw_rect(dc, pixel, color, fill);
    }

    function draw_layout(dc as gfx.Dc) as Void {
        draw_circle(dc, SUBSCREEN, FOREGROUND_COLOR, true);
        draw_rect(dc, BANNER_TOP, FOREGROUND_COLOR, false);
        draw_rect(dc, BANNER_BOTTOM, FOREGROUND_COLOR, false);
    }

    function draw_circle(dc as gfx.Dc, circle as tl.Circle, color as gfx.ColorValue, fill as tl.Bool) as Void {
        dc.setColor(color, TRANSPARENT_COLOR);
        if (fill) {
            dc.fillCircle(circle.x, circle.y, circle.r);
        } else {
            dc.drawCircle(circle.x, circle.y, circle.r);
        }
    }

    function draw_rect(dc as gfx.Dc, rect as tl.Rect, color as gfx.ColorValue, fill as tl.Bool) as Void {
        dc.setColor(color, TRANSPARENT_COLOR);
        if (fill) {
            dc.fillRectangle(rect.x, rect.y, rect.width, rect.height);
        } else {
            dc.drawRectangle(rect.x, rect.y, rect.width, rect.height);
        }
    }

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
        /* TODO */
    }

    function set_frequency(freq as tl.U32) as Void {
        /* TODO */
    }

    function play_frequency(en as tl.Bool) as Void {
        /* TODO */
    }

    function handler() as tl.Int {
        /* TODO */
        return 0;
    }

}
