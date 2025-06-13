import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Lang;
import Toybox.Math;

using tamalib as tl;

class GarminGotchiView extends WatchUi.View {

    const GAME_LOG_LEVEL_FLAGS = (
        tl.LOG_ERROR
        // | tl.LOG_INFO
        // | tl.LOG_MEMORY
        // | tl.LOG_CPU
        // | tl.LOG_INT
    );
    const GAME_RUN_TIMER_MS = 10;
    const GAME_RUN_MAX_STEPS = 120;
    const GAME_DRAW_TIMER_MS = 500;
    const GAME_FOREGROUND_COLOR = Graphics.COLOR_WHITE;
    const GAME_BACKGROUND_COLOR = Graphics.COLOR_BLACK;

    var game as tl.Tamalib = new tl.Tamalib_impl() as tl.Tamalib;
    var game_start_time as tl.Int = System.getTimer();
    var game_run_timer as Timer.Timer = new Timer.Timer();
    var game_draw_timer as Timer.Timer = new Timer.Timer();
    var game_breakpoints as Array<tl.Breakpoint> = [];

    (:initialized) var SCREEN as tl.Rect;
    (:initialized) var SUBSCREEN as tl.Circle;
    (:initialized) var MATRIX as tl.Rect;
    (:initialized) var BANNER_TOP as tl.Rect;
    (:initialized) var BANNER_BOTTOM as tl.Rect;
    (:initialized) var MATRIX_PIXEL_SIZE as tl.Int;
    var matrix as ByteArray = new [tl.LCD_WIDTH * tl.LCD_HEIGHT]b;

    function initialize() {
        View.initialize();

        game.register_hal(me);
        game.init(tl.program, game_breakpoints, 1000000);
        game.set_speed(0);
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));

        compute_layout(dc);

        game_run_timer.start(method(:game_run_max_steps), GAME_RUN_TIMER_MS, true);
        game_draw_timer.start(method(:update_screen), GAME_DRAW_TIMER_MS, true);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {}

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        clear_screen(dc);
        draw_matrix(dc);
        draw_layout(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        game.release();
        game.free_bp(game_breakpoints);
    }

    /* game logic */

    // TODO: move game logic to separate class

    function game_run_max_steps() as Void {
        for (var i = 0; i < GAME_RUN_MAX_STEPS; i++) {
            game.step();
        }
    }

    /* graphics function */

    // TODO: move app graphics logic to separate class

    function compute_layout(dc as Dc) as Void {
        SCREEN = new tl.Rect(0, 0, dc.getWidth(), dc.getHeight());
        SUBSCREEN = tl.bbox_to_circle(WatchUi.getSubscreen() as BoundingBox);
        MATRIX_PIXEL_SIZE = tl.min(SCREEN.width / tl.LCD_WIDTH, SCREEN.height / tl.LCD_HEIGHT) as tl.Int;

        var MATRIX_WIDTH = tl.min(SCREEN.width, tl.LCD_WIDTH * MATRIX_PIXEL_SIZE) as tl.Int;
        var MATRIX_HEIGHT = tl.min(SCREEN.height, tl.LCD_HEIGHT * MATRIX_PIXEL_SIZE) as tl.Int;
        MATRIX = new tl.Rect(
            (SCREEN.width - MATRIX_WIDTH) / 2,
            (SCREEN.height - MATRIX_HEIGHT) / 2,
            MATRIX_WIDTH,
            MATRIX_HEIGHT
        );

        BANNER_TOP = new tl.Rect(MATRIX.x, 0, MATRIX.width, MATRIX.y);
        BANNER_BOTTOM = new tl.Rect(MATRIX.x, MATRIX.y + MATRIX.height, MATRIX.width, MATRIX.y);
    }

    function clear_screen(dc as Dc) as Void {
        dc.setColor(GAME_FOREGROUND_COLOR, GAME_BACKGROUND_COLOR);
        dc.clear();
    }

    function draw_matrix(dc as Dc) as Void {
        for (var x = 0; x < tl.LCD_WIDTH; x++) {
            for (var y = 0; y < tl.LCD_HEIGHT; y++) {
                if (tl.bool(matrix[x + y * tl.LCD_WIDTH])) {
                    draw_pixel(dc, x, y, GAME_FOREGROUND_COLOR, true);
                } else {
                    draw_pixel(dc, x, y, GAME_BACKGROUND_COLOR, false);
                }
            }
        }
    }

    function draw_pixel(dc as Dc, x as tl.Int, y as tl.Int, color as Graphics.ColorValue, fill as tl.Bool) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        if (fill) {
            dc.fillRectangle(
                MATRIX.x + (x * MATRIX_PIXEL_SIZE),
                MATRIX.y + (y * MATRIX_PIXEL_SIZE),
                MATRIX_PIXEL_SIZE,
                MATRIX_PIXEL_SIZE
            );
        } else {
            dc.drawRectangle(
                MATRIX.x + (x * MATRIX_PIXEL_SIZE),
                MATRIX.y + (y * MATRIX_PIXEL_SIZE),
                MATRIX_PIXEL_SIZE,
                MATRIX_PIXEL_SIZE
            );
        }
    }

    function draw_layout(dc as Dc) as Void {
        draw_circle(dc, SUBSCREEN, GAME_FOREGROUND_COLOR, true);
        draw_rect(dc, BANNER_TOP, GAME_FOREGROUND_COLOR, false);
        draw_rect(dc, BANNER_BOTTOM, GAME_FOREGROUND_COLOR, false);
    }

    function draw_circle(dc as Dc, circle as tl.Circle, color as Graphics.ColorValue, fill as tl.Bool) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        if (fill) {
            dc.fillCircle(circle.x, circle.y, circle.r);
        } else {
            dc.drawCircle(circle.x, circle.y, circle.r);
        }
    }

    function draw_rect(dc as Dc, rect as tl.Rect, color as Graphics.ColorValue, fill as tl.Bool) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        if (fill) {
            dc.fillRectangle(rect.x, rect.y, rect.width, rect.height);
        } else {
            dc.drawRectangle(rect.x, rect.y, rect.width, rect.height);
        }
    }

    /* HAL interface implementation */

    /* TODO: move game logic to separate class */

    function malloc(size as tl.U32) as Object? { return null; }

    function free(ptr as Object?) as Void {}

    function halt() as Void {}

    function is_log_enabled(level as tl.LogLevel) as tl.Bool {
        return tl.bool(GAME_LOG_LEVEL_FLAGS & (level as tl.Int));
    }

    function log(level as tl.LogLevel, buff as String, args as Array<Object>) as Void {
        if (is_log_enabled(level)) {
            tl.printf(buff, args);
        }
    }

    function sleep_until(ts as tl.Timestamp) as Void {
        var t0 = get_timestamp();
        while (get_timestamp() - t0 < ts) {}
    }

    function get_timestamp() as tl.Timestamp {
        return System.getTimer() - game_start_time;
    }

    function update_screen() as Void {
        WatchUi.requestUpdate();
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
