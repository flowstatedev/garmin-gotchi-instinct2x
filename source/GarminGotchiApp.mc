using Toybox.Application as app;
using Toybox.WatchUi as ui;
using Toybox.Lang;

class GarminGotchiApp extends app.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Lang.Dictionary?) as Void {}

    // onStop() is called when your application is exiting
    function onStop(state as Lang.Dictionary?) as Void {}

    // Return the initial view of your application here
    function getInitialView() as [ui.Views] or [ui.Views, ui.InputDelegates] {
        return [ new GarminGotchiView(), new GarminGotchiDelegate() ];
    }

}

function getApp() as GarminGotchiApp {
    return app.getApp() as GarminGotchiApp;
}
