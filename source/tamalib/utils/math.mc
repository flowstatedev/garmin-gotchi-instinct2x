import Toybox.Lang;
import Toybox.Math;

module tamalib {

function round(val as Float) as Int {
    return Math.round(val).toNumber();
}

function max(a as Num, b as Num) as Num {
    return (a > b) ? a : b;
}

function min(a as Num, b as Num) as Num {
    return (a < b) ? a : b;
}

}
