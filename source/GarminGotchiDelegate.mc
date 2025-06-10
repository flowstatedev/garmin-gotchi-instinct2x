import Toybox.Lang;
import Toybox.WatchUi;

class GarminGotchiDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new GarminGotchiMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}
