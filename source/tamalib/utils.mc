module tamalib {

function to_int(val as Bool) as Int {
    return (val) ? 1 : 0;
}

function to_bool(val as Int) as Bool {
    return val != 0;
}

}
