using Toybox.System as sys;
using Toybox.Lang;

module tamalib {

function printf(c_fmt as String, params as Objects) as Void {
    sys.print(fmt(c_fmt, params));
}

function fmt(c_fmt as String, params as Objects) as String {
    return new Fmt(c_fmt).convert(params);
}

class Fmt {

    class IndexTuple {
        var start as Int;
        var end as Int;

        function initialize(start as Int, end as Int) {
            me.start = start;
            me.end = end;
        }
    }

    typedef IndexTuples as Lang.Array<IndexTuple>;

    var _base_format as String;
    var _param_formats as Strings;

    function initialize(c_fmt as String) {
        var indexes = _find_c_format_indexes(c_fmt);
        _base_format = _convert_c_format(c_fmt, indexes);
        _param_formats = _extract_param_formats(c_fmt, indexes);
    }

    function convert(params as Objects) as String {
        params = _apply_param_formats(params, _param_formats);
        return format(_base_format, params as Lang.Array);
    }

    function _find_c_format_indexes(c_fmt as String) as IndexTuples {
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

    function _convert_c_format(c_fmt as String, fmt_indexes as IndexTuples) as String {
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

    function _extract_param_formats(c_fmt as String, fmt_indexes as IndexTuples) as Strings {
        var fmt_arr = [];
        for (var i = 0; i < fmt_indexes.size(); i++) {
            var fmt_idx = fmt_indexes[i];
            fmt_arr.add(c_fmt.substring(fmt_idx.start, fmt_idx.end));
        }
        return fmt_arr as Strings;
    }

    function _apply_param_formats(params as Objects, formats as Strings) as Strings {
        var str_arr = [];
        for (var fmt_i = 0; fmt_i < formats.size(); fmt_i++) {
            var param = params[fmt_i];
            switch (param) {
                case instanceof Lang.Float:
                case instanceof Lang.Number:
                    str_arr.add((param as Float or Int).format(formats[fmt_i]));
                    break;
                default:
                    str_arr.add(param.toString());
            }
        }
        return str_arr;
    }

}

}
