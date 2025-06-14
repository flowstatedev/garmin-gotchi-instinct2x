using Toybox.Graphics as gfx;
using Toybox.WatchUi as ui;

using tamalib as tl;

class GarminGotchiGraphics {

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

    (:initialized) var matrix as tl.Bytes;
    (:initialized) var pixel as tl.Rect;

    function init(dc as gfx.Dc, matrix as tl.Bytes) as Void {
        me.matrix = matrix;

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

    function draw(dc as gfx.Dc) as Void {
        clear_screen(dc);
        draw_matrix(dc);
        draw_layout(dc);
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

}
