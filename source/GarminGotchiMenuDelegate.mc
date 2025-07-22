using Toybox.System as sys;
using Toybox.WatchUi as ui;
import Toybox.Lang;

class GarminGotchiMenuDelegate extends ui.MenuInputDelegate {

    var game as GarminGotchiApp;

    function initialize(game as GarminGotchiApp) {
        MenuInputDelegate.initialize();
        me.game = game;

        game.pause();
    }

    function onMenuItem(item as Symbol) as Void {
        switch (item) {
            case :MenuResume:
                break;

            case :MenuSound:
                game.sound_toggle();
                break;

            case :MenuSave:
                game.save();
                break;

            case :MenuLoad:
                game.load();
                break;

            case :MenuExit:
                sys.exit();

            case :MenuRestart:
                game.reset();
                break;

            default:
                break;
        }

        game.start();
    }

}
