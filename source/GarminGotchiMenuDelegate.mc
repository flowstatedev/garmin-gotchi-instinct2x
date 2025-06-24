using Toybox.System as sys;
using Toybox.WatchUi as ui;
using Toybox.Lang;

class GarminGotchiMenuDelegate extends ui.MenuInputDelegate {

    var game as GarminGotchiApp;

    function initialize(game as GarminGotchiApp) {
        MenuInputDelegate.initialize();
        me.game = game;
        pause();
    }

    function onMenuItem(item as Lang.Symbol) as Void {
        switch (item) {
            case :MenuSave:
                save();
            case :MenuResume:
                break;

            case :MenuSaveAndExit:
                save();
            case :MenuExit:
                sys.exit();

            case :MenuRestart:
                restart();
                break;

            default:
                break;
        }
        resume();
    }

    function resume() as Void {
        game.start_execution();
    }

    function pause() as Void {
        game.pause_execution();
    }

    function restart() as Void {
        game.reset_execution();
    }

    function save() as Void {
        /** TODO: save game state here */
    }

}
