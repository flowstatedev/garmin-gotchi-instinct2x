using Toybox.Application as app;
using Toybox.Graphics as gfx;
using Toybox.WatchUi as ui;
using Toybox.Timer as time;
using Toybox.Lang;

using tamalib as tl;

class GarminGotchiView extends ui.View {

    const DRAW_TIMER_PERIOD_MS = 500;
    (:initialized) var SCREEN as tl.Rect;
    (:initialized) var SUBSCREEN_RECT as tl.Rect;
    (:initialized) var SUBSCREEN_CIRCLE as tl.Circle;
    (:initialized) var MATRIX as tl.Rect;
    (:initialized) var PIXEL_SIZE as tl.Int;
    typedef BitmapResources as Lang.Array<ui.BitmapResource>;
    (:initialized) var ICON_BITMAPS as BitmapResources;

    var game as GarminGotchiApp;
    var draw_timer as time.Timer = new time.Timer();

    function initialize(game as GarminGotchiApp) {
        View.initialize();
        me.game = game;
    }

    function onLayout(dc as gfx.Dc) as Void {
        setLayout(Rez.Layouts.Layout(dc));
        compute_layout(dc);
    }

    function onShow() as Void {
        draw_timer.start(method(:draw_timer_callback), DRAW_TIMER_PERIOD_MS, true);
    }

    function onUpdate(dc as gfx.Dc) as Void {
        View.onUpdate(dc);
        draw_screen(dc);
    }

    function onHide() as Void {
        draw_timer.stop();
    }

    function compute_layout(dc as gfx.Dc) as Void {
        SCREEN = new tl.Rect(0, 0, dc.getWidth(), dc.getHeight());
        SUBSCREEN_RECT = tl.bbox_to_rect(ui.getSubscreen() as gfx.BoundingBox);
        SUBSCREEN_CIRCLE = tl.bbox_to_circle(ui.getSubscreen() as gfx.BoundingBox);
        PIXEL_SIZE = tl.min(SCREEN.width / tl.LCD_WIDTH, SCREEN.height / tl.LCD_HEIGHT) as tl.Int;
        var MATRIX_WIDTH = tl.min(SCREEN.width, tl.LCD_WIDTH * PIXEL_SIZE) as tl.Int;
        var MATRIX_HEIGHT = tl.min(SCREEN.height, tl.LCD_HEIGHT * PIXEL_SIZE) as tl.Int;
        MATRIX = new tl.Rect(
            (SCREEN.width - MATRIX_WIDTH) / 2,
            (SCREEN.height - MATRIX_HEIGHT) / 2,
            MATRIX_WIDTH,
            MATRIX_HEIGHT
        );
        ICON_BITMAPS = [
            app.loadResource(Rez.Drawables.IconFood),
            app.loadResource(Rez.Drawables.IconLight),
            app.loadResource(Rez.Drawables.IconGame),
            app.loadResource(Rez.Drawables.IconMedicine),
            app.loadResource(Rez.Drawables.IconBathroom),
            app.loadResource(Rez.Drawables.IconMeter),
            app.loadResource(Rez.Drawables.IconDiscipline),
            app.loadResource(Rez.Drawables.IconAttention),
        ] as BitmapResources;
    }

    function draw_timer_callback() as Void {
        game.update_screen();
    }

    function draw_screen(dc as gfx.Dc) as Void {
        clear_screen(dc);
        draw_matrix(dc);
        clear_subscreen(dc);
        draw_icon(dc);
    }

    function clear_screen(dc as gfx.Dc) as Void {
        dc.setColor(gfx.COLOR_WHITE, gfx.COLOR_TRANSPARENT);
        dc.clear();
    }

    function clear_subscreen(dc as gfx.Dc) as Void {
        draw_circle(dc, SUBSCREEN_CIRCLE, gfx.COLOR_BLACK, true);
    }

    function draw_matrix(dc as gfx.Dc) as Void {
        for (var x = 0; x < tl.LCD_WIDTH; x++) {
            for (var y = 0; y < tl.LCD_HEIGHT; y++) {
                if (tl.bool(game.matrix[x + y * tl.LCD_WIDTH])) {
                    draw_pixel(dc, x, y);
                }
            }
        }
    }

    function draw_pixel(dc as gfx.Dc, x as tl.Int, y as tl.Int) as Void {
        var pixel = new tl.Rect(
            MATRIX.x + (x * PIXEL_SIZE),
            MATRIX.y + (y * PIXEL_SIZE),
            PIXEL_SIZE,
            PIXEL_SIZE
        );
        draw_rect(dc, pixel, gfx.COLOR_BLACK, true);
    }

    function draw_icon(dc as gfx.Dc) as Void {
        dc.setColor(gfx.COLOR_WHITE, gfx.COLOR_TRANSPARENT);
        for (var i = 0; i < game.icons.size(); i++) {
            if (game.icons[i] != 0) {
                dc.drawBitmap(SUBSCREEN_RECT.x, SUBSCREEN_RECT.y, ICON_BITMAPS[i]);
                break;
            }
        }
    }

    function draw_circle(dc as gfx.Dc, circle as tl.Circle, color as gfx.ColorValue, fill as tl.Bool) as Void {
        dc.setColor(color, gfx.COLOR_TRANSPARENT);
        if (fill) {
            dc.fillCircle(circle.x, circle.y, circle.r);
        } else {
            dc.drawCircle(circle.x, circle.y, circle.r);
        }
    }

    function draw_rect(dc as gfx.Dc, rect as tl.Rect, color as gfx.ColorValue, fill as tl.Bool) as Void {
        dc.setColor(color, gfx.COLOR_TRANSPARENT);
        if (fill) {
            dc.fillRectangle(rect.x, rect.y, rect.width, rect.height);
        } else {
            dc.drawRectangle(rect.x, rect.y, rect.width, rect.height);
        }
    }

}
