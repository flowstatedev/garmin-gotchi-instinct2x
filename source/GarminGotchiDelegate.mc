using Toybox.WatchUi as ui;
using Toybox.Lang;

class GarminGotchiDelegate extends ui.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Lang.Boolean {
        ui.pushView(new Rez.Menus.MainMenu(), new GarminGotchiMenuDelegate(), ui.SLIDE_UP);
        return true;
    }

}
