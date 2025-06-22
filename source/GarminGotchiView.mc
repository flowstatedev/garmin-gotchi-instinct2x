using Toybox.Graphics as gfx;
using Toybox.WatchUi as ui;

class GarminGotchiView extends ui.View {

    var game as GarminGotchiGame;

    function initialize(game as GarminGotchiGame) {
        View.initialize();
        me.game = game;
    }

    function onLayout(dc as gfx.Dc) as Void {
        setLayout(Rez.Layouts.Layout(dc));
        game.compute_layout(dc);
    }

    function onShow() as Void {}

    function onUpdate(dc as gfx.Dc) as Void {
        View.onUpdate(dc);
        game.draw(dc);
    }

    function onHide() as Void {}

}
