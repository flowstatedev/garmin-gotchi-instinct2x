/*
 * TamaLIB - A hardware agnostic Tamagotchi P1 emulation library
 *
 * Copyright (C) 2021 Jean-Christophe Rona <jc@rona.fr>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as Lang.published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

using Toybox.Lang as std;

module tamalib {

/* Standard types */
typedef Bool as std.Boolean;
typedef Int as std.Number;
typedef Float as std.Float;
typedef Num as Int or Float;
typedef Bytes as std.ByteArray;
typedef Object as std.Object;
typedef Objects as std.Array<Object>;
typedef String as std.String;
typedef Strings as std.Array<String>;

/* HAL types */
typedef U4 as Int;
typedef U5 as Int;
typedef U8 as Int;
typedef U12 as Int;
typedef U13 as Int;
typedef U32 as Int;
typedef Timestamp as Int;
typedef Program as Bytes;
typedef Memory as Bytes;

}
