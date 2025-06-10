import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Lang;

class GarminGotchiView extends WatchUi.View {

    const GAME_RUN_TIMER_MS = 50;
    const GAME_RUN_MAX_STEPS = 10;
    var game_run_timer = new Timer.Timer();

    const GAME_DRAW_TIMER_MS = 1000;
    var game_draw_timer = new Timer.Timer();

    var game_breakpoints = [];

    var game = new tamalib.Tamalib_impl(
        tamalib.LOG_ERROR | tamalib.LOG_INFO | tamalib.LOG_MEMORY | tamalib.LOG_CPU | tamalib.LOG_INT
    );

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

        game_init();
        game_run_timer.start(method(:game_run), GAME_RUN_TIMER_MS, true);
        game_draw_timer.start(method(:game_draw), GAME_DRAW_TIMER_MS, true);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {}

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        dc.clear();

        // TODO: Draw screen here
        // ...
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2,
            Graphics.FONT_MEDIUM,
            game.g_hal.get_timestamp().format("%d"),
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        game.release();
        game.free_bp(game_breakpoints);
    }

    function game_init() as Void {
        game.init(tamalib.program, game_breakpoints, 100);
        game.set_speed(0);
    }

    function game_run() as Void {
        for (var i = 0; i < GAME_RUN_MAX_STEPS; i++) {
            game.step();
        }
    }

    function game_draw() as Void {
        WatchUi.requestUpdate();
    }

}
