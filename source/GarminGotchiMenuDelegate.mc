import Toybox.Lang;
import Toybox.WatchUi;

class GarminGotchiMenuDelegate extends Menu2InputDelegate {

    var game as GarminGotchiApp;

    function initialize(game as GarminGotchiApp) {
        Menu2InputDelegate.initialize();
        me.game = game;

        game.pause();
    }

    function onSelect(item as MenuItem) as Void {
        var id = item.getId() as Symbol;
        switch (id) {
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
                System.exit();

            case :MenuRestart:
                game.reset();
                break;

            default:
                break;
        }

        onBack();
    }

    function onBack() as Void {
        game.start();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

}
