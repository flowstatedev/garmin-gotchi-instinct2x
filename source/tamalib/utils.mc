import Toybox.System;
import Toybox.Lang;

module tamalib {

typedef IntArray as Array<Int>;
typedef BoolArray as Array<Bool>;

function int(val as Bool) as Int {
    return (val) ? 1 : 0;
}

function bool(val as Int) as Bool {
    return val != 0;
}

function fmt(c_fmt as String, params as Array<Object>) as String {
    return new Fmt(c_fmt).convert(params);
}

function printf(c_fmt as String, params as Array<Object>) as Void {
    System.print(fmt(c_fmt, params));
}

class Fmt {

    class IndexTuple {
        var start;
        var end;

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
        return format(_base_format, params);
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
            if ((fmt_start != null) and (fmt_end == null)) {
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
        return fmt_arr;
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
