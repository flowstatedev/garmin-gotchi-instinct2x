using Toybox.WatchUi as ui;
using Toybox.Lang;

class GarminGotchiDelegate extends ui.BehaviorDelegate {

    var game as GarminGotchiGame;
 
    function initialize(game as GarminGotchiGame) {
        ui.BehaviorDelegate.initialize();
        me.game = game;
    }

    function onMenu() as Lang.Boolean {
        ui.pushView(new Rez.Menus.MainMenu(), new GarminGotchiMenuDelegate(), ui.SLIDE_UP);
        return true;
    }

    function onPreviousPage() as Lang.Boolean {
        game.press_left();
        return true;
    }

    function onNextPage() as Lang.Boolean {
        game.press_right();
        return true;
    }

    function onSelect() as Lang.Boolean {
        game.press_middle();
        return true;
    }

    function onBack() as Lang.Boolean {
        game.press_tap();
        return true;
    }

}
