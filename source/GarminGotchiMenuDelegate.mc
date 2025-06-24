using Toybox.System as sys;
using Toybox.WatchUi as ui;
using Toybox.Lang;

class GarminGotchiMenuDelegate extends ui.MenuInputDelegate {

    var game as GarminGotchiApp;

    function initialize(game as GarminGotchiApp) {
        MenuInputDelegate.initialize();
        me.game = game;
        me.game.pause_execution();
    }

    function onMenuItem(item as Lang.Symbol) as Void {
        switch (item) {
            case :MenuResume:
                game.start_execution();
                break;
            case :MenuSave:
                /* TODO: save game state here */
                break;
            case :MenuLoad:
                /* TODO: load game state here */
                break;
            case :MenuExit:
                game.stop_execution();
                sys.exit();
            default:
                break;
        }
    }

}
