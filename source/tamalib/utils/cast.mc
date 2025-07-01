using Toybox.Lang as std;

module tamalib {

function int(val as Bool or Num) as Int {
    switch (val) {
        case instanceof std.Boolean:
            return (val as Bool) ? 1 : 0;
        default:
            return (val as Num).toNumber();
    }
}

function bool(val as Int) as Bool {
    return val != 0;
}

function float(val as Int) as Float {
    return val.toFloat();
}

}
