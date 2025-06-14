import Toybox.Graphics;

module tamalib {

class Circle {
    var x as Int;
    var y as Int;
    var r as Int;

    function initialize(x as Int, y as Int, r as Int) {
        me.x = x;
        me.y = y;
        me.r = r;
    }
}

function bbox_to_circle(box as BoundingBox) as Circle {
    var r = float(box.width) / 2;
    var x = (box.x as Int) + r;
    var y = (box.y as Int) + r;
    return new Circle(round(x), round(y), round(r));
}

class Rect {
    var x as Int;
    var y as Int;
    var width as Int;
    var height as Int;

    function initialize(x as Int, y as Int, width as Int, height as Int) {
        me.x = x;
        me.y = y;
        me.width = width;
        me.height = height;
    }
}

function bbox_to_rect(box as BoundingBox) as Rect {
    return new Rect(box.x as Int, box.y as Int, box.width, box.height);
}

}
