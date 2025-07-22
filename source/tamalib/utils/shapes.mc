using Toybox.Graphics as gfx;

module tamalib {

typedef Shape as Circle or Rect;

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

function bbox_to_circle(box as gfx.BoundingBox or Rect) as Circle {
    var r = box.width / 2.0;
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

function bbox_to_rect(box as gfx.BoundingBox) as Rect {
    return new Rect(box.x as Int, box.y as Int, box.width, box.height);
}

}
