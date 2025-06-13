import Toybox.System;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Graphics;

module tamalib {

typedef IntArray as Array<Int>;
typedef BoolArray as Array<Bool>;

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

function int(val as Bool or Numeric) as Int {
    switch (val) {
        case instanceof Boolean:
            return (val as Boolean) ? 1 : 0;
        default:
            return (val as Numeric).toNumber();
    }
}

function bool(val as Int) as Bool {
    return val != 0;
}

function float(val as Int) as Float {
    return val.toFloat();
}

function round(val as Float) as Int {
    return Math.round(val).toNumber();
}

function max(a as Numeric, b as Numeric) as Numeric {
    return (a > b) ? a : b;
}

function min(a as Numeric, b as Numeric) as Numeric {
    return (a < b) ? a : b;
}

function fmt(c_fmt as String, params as Array<Object>) as String {
    return new Fmt(c_fmt).convert(params);
}

function printf(c_fmt as String, params as Array<Object>) as Void {
    System.print(fmt(c_fmt, params));
}

class Fmt {

    class IndexTuple {
        var start as Number;
        var end as Number;

        function initialize(start as Number, end as Number) {
            me.start = start;
            me.end = end;
        }
    }

    var _base_format as String;
    var _param_formats as Array<String>;

    function initialize(c_fmt as String) {
        var indexes = _find_c_format_indexes(c_fmt);
        _base_format = _convert_c_format(c_fmt, indexes);
        _param_formats = _extract_param_formats(c_fmt, indexes);
    }

    function convert(params as Array<Object>) as String {
        params = _apply_param_formats(params, _param_formats);
        return format(_base_format, params as Array);
    }

    function _find_c_format_indexes(c_fmt as String) as Array<IndexTuple> {
        var fmt_start = null;
        var fmt_end = null;
        var indexes = [];
        var idx = 0;

        c_fmt = c_fmt.toCharArray();
        while (idx < c_fmt.size()) {
            if (c_fmt[idx] == '%') {
                fmt_start = idx;
                fmt_end = null;
            }
            if ((fmt_start != null) && (fmt_end == null)) {
                switch (c_fmt[idx]) {
                    case 'd': case 'i': // signed decimal integer
                    case 'u':           // unsigned decimal integer
                    case 'o':           // signed octal integer
                    case 'x': case 'X': // unsigned hexadecimal integer
                    case 'e': case 'E': // scientific notation (mantissa/exponent)
                    case 'f':           // decimal floating point
                    case 's':           // string
                        fmt_end = idx + 1;
                        indexes.add(new IndexTuple(fmt_start, fmt_end));
                        break;
                    default:
                        break;
                }
            }
            idx++;
        }
        return indexes;
    }

    function _convert_c_format(c_fmt as String, fmt_indexes as Array<IndexTuple>) as String {
        var idx = 0;
        var fmt = "";
        var fmt_idx = new IndexTuple(0, 0);
        for (var i = 0; i < fmt_indexes.size(); i++) {
            fmt_idx = fmt_indexes[i];
            fmt += c_fmt.substring(idx, fmt_idx.start) + "$" + (i+1).toString() + "$";
            idx = fmt_idx.end;
        }
        fmt += c_fmt.substring(fmt_idx.end, null);
        return fmt;
    }

    function _extract_param_formats(c_fmt as String, fmt_indexes as Array<IndexTuple>) as Array<String> {
        var fmt_arr = [];
        for (var i = 0; i < fmt_indexes.size(); i++) {
            var fmt_idx = fmt_indexes[i];
            fmt_arr.add(c_fmt.substring(fmt_idx.start, fmt_idx.end));
        }
        return fmt_arr as Array<String>;
    }

    function _apply_param_formats(params as Array<Object>, formats as Array<String>) as Array<String> {
        var str_arr = [];
        for (var fmt_i = 0; fmt_i < formats.size(); fmt_i++) {
            var param = params[fmt_i];
            switch (param) {
                case instanceof Float:
                case instanceof Number:
                    str_arr.add((param as Float or Number).format(formats[fmt_i]));
                    break;
                default:
                    str_arr.add(param.toString());
            }
        }
        return str_arr;
    }

}

}
