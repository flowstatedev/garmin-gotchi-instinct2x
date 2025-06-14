using Toybox.Application as app;
using Toybox.WatchUi as ui;
using Toybox.Lang;

class GarminGotchiApp extends app.AppBase {

    var game as GarminGotchiGame = new GarminGotchiGame();

    function initialize() {
        AppBase.initialize();
        game.init();
    }

    function onStart(state as Lang.Dictionary?) as Void {
        game.start();
    }

    function onStop(state as Lang.Dictionary?) as Void {
        game.stop();
    }

    function getInitialView() as [ui.Views] or [ui.Views, ui.InputDelegates] {
        return [ new GarminGotchiView(game), new GarminGotchiDelegate() ];
    }

}

function getApp() as GarminGotchiApp {
    return app.getApp() as GarminGotchiApp;
}
