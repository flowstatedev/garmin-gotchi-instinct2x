using Toybox.Application as app;
using Toybox.Graphics as gfx;
using Toybox.WatchUi as ui;
using Toybox.Timer as time;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

using tamalib as tama;
import tamalib;

class GarminGotchiView extends ui.View {

    typedef BitmapResources as Array<BitmapType>;

    (:standard_colors) const COLOR_WHITE = gfx.COLOR_WHITE;
    (:inverted_colors) const COLOR_WHITE = gfx.COLOR_BLACK;
    (:standard_colors) const COLOR_BLACK = gfx.COLOR_BLACK;
    (:inverted_colors) const COLOR_BLACK = gfx.COLOR_WHITE;
                       const COLOR_EMPTY = gfx.COLOR_TRANSPARENT;

    (:initialized) var SCREEN as tama.Rect;
    (:initialized) var SUBSCREEN_RECT as tama.Rect;
    (:initialized) var SUBSCREEN_CIRCLE as tama.Circle;
    (:initialized) var MATRIX as tama.Rect;
    (:initialized) var PIXEL_SIZE as tama.Int;
    // (:initialized) var ICON_BITMAPS as BitmapResources;
    (:initialized) var BACKGROUND as BitmapType?;

    (:initialized) const ICON_BITMAPS as Array<Symbol> = [
        :IconFood,
        :IconLight,
        :IconGame,
        :IconMedicine,
        :IconBathroom,
        :IconMeter,
        :IconDiscipline,
        :IconAttention,
    ]; // The size of ICON_BITMAPS[] should be ICON_NUM (8)

    var game as GarminGotchiApp;

    function initialize(game as GarminGotchiApp) {
        View.initialize();
        me.game = game;
    }

    function onLayout(dc as gfx.Dc) as Void {
        // setLayout(Rez.Layouts.Layout(dc));
        compute_layout(dc);
    }

    function onShow() as Void {}

    function onUpdate(dc as gfx.Dc) as Void {
        // View.onUpdate(dc);
        dc.drawBitmap(0, 0, BACKGROUND as BitmapType);
        draw_screen(dc);
    }

    function onHide() as Void {}

    function getSubscreen() as Rect {
        var box = null;
        if (WatchUi has :getSubscreen) {
            // instinct2x, instinct3 (solar)
            box = WatchUi.getSubscreen() as Graphics.BoundingBox;
            return tama.bbox_to_rect(box);
        } else {
            // hardcode for fr955
            box = new Rect(165, 25, 62, 62);
        }
        return box;
    }

    function compute_layout(dc as gfx.Dc) as Void {
        SCREEN = new tama.Rect(0, 0, dc.getWidth(), dc.getHeight());
        var subscreenRect = getSubscreen();
        SUBSCREEN_RECT = subscreenRect;
        SUBSCREEN_CIRCLE = tama.bbox_to_circle(subscreenRect);
        PIXEL_SIZE = tama.min(SCREEN.width / tama.LCD_WIDTH, SCREEN.height / tama.LCD_HEIGHT) as tama.Int;
        var MATRIX_WIDTH = tama.min(SCREEN.width, tama.LCD_WIDTH * PIXEL_SIZE) as tama.Int;
        var MATRIX_HEIGHT = tama.min(SCREEN.height, tama.LCD_HEIGHT * PIXEL_SIZE) as tama.Int;
        MATRIX = new tama.Rect(
            (SCREEN.width - MATRIX_WIDTH) / 2,
            (SCREEN.height - MATRIX_HEIGHT) / 2,
            MATRIX_WIDTH,
            MATRIX_HEIGHT
        );
        BACKGROUND = app.loadResource(Rez.Drawables.Background) as BitmapType;
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
        dc.setColor(COLOR_WHITE, COLOR_EMPTY);
        dc.clear();
    }

    function clear_subscreen(dc as gfx.Dc) as Void {
        // draw_circle(dc, SUBSCREEN_CIRCLE, COLOR_BLACK, true);
        dc.setColor(COLOR_BLACK, COLOR_EMPTY);
        dc.fillCircle(SUBSCREEN_CIRCLE.x, SUBSCREEN_CIRCLE.y, SUBSCREEN_CIRCLE.r);
    }

    function draw_matrix(dc as gfx.Dc) as Void {
        dc.setColor(COLOR_BLACK, COLOR_EMPTY);

        for (var x = 0; x < tama.LCD_WIDTH; x++) {
            for (var y = 0; y < tama.LCD_HEIGHT; y++) {
                if (game.matrix[x + y * tama.LCD_WIDTH] != 0) {
                    // draw_pixel(dc, x, y);
                    dc.fillRectangle(
                        MATRIX.x + (x * PIXEL_SIZE),
                        MATRIX.y + (y * PIXEL_SIZE),
                        PIXEL_SIZE,
                        PIXEL_SIZE
                    );
                }
            }
        }
    }

    // function draw_pixel(dc as gfx.Dc, x as tama.Int, y as tama.Int) as Void {
        // var pixel = new tama.Rect(
        //     MATRIX.x + (x * PIXEL_SIZE),
        //     MATRIX.y + (y * PIXEL_SIZE),
        //     PIXEL_SIZE,
        //     PIXEL_SIZE
        // );

        // draw_rect(dc, pixel, COLOR_BLACK, true);
    // }

    var last_icon_symbol as Symbol? = null;
    var last_icon_resource as BitmapType? = null;

    // const TEST_ICONS = true; // TEST: uncomment this line to force icon to be displayed; this helps test worst-case peak memory usage
    const TEST_ICONS = false; // uncomment this line for release

    function draw_icon(dc as gfx.Dc) as Void {
        dc.setColor(COLOR_WHITE, COLOR_EMPTY);
        for (var i = 0; i < game.icons.size(); i++) {
            if (game.icons[i] != 0 || TEST_ICONS) {
                var current_icon_symbol = ICON_BITMAPS[i];
                if (last_icon_symbol != current_icon_symbol) {
                    last_icon_symbol = current_icon_symbol;
                    last_icon_resource = app.loadResource(Rez.Drawables[ICON_BITMAPS[i]] as ResourceId) as BitmapType;
                }
                dc.drawBitmap(SUBSCREEN_RECT.x, SUBSCREEN_RECT.y, last_icon_resource as BitmapType);
                break;
            }
        }
    }

    // function draw_circle(dc as gfx.Dc, circle as tama.Circle, color as gfx.ColorValue, fill as tama.Bool) as Void {
    //     dc.setColor(color, COLOR_EMPTY);
    //     if (fill) {
    //         dc.fillCircle(circle.x, circle.y, circle.r);
    //     } else {
    //         dc.drawCircle(circle.x, circle.y, circle.r);
    //     }
    // }

    // function draw_rect(dc as gfx.Dc, rect as tama.Rect, color as gfx.ColorValue, fill as tama.Bool) as Void {
    //     dc.setColor(color, COLOR_EMPTY);
    //     if (fill) {
    //         dc.fillRectangle(rect.x, rect.y, rect.width, rect.height);
    //     } else {
    //         dc.drawRectangle(rect.x, rect.y, rect.width, rect.height);
    //     }
    // }

}
