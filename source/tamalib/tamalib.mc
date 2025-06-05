/*
 * TamaLIB - A hardware agnostic Tamagotchi P1 emulation library
 *
 * Copyright (C) 2021 Jean-Christophe Rona <jc@rona.fr>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
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

import Toybox.Lang;

module tamalib {

enum ExecMode {
    EXEC_MODE_PAUSE,
    EXEC_MODE_RUN,
    EXEC_MODE_STEP,
    EXEC_MODE_NEXT,
    EXEC_MODE_TO_CALL,
    EXEC_MODE_TO_RET,
}

typedef Tamalib as interface {
    function release() as Void;
    function init(program as Program, breakpoints as BreakpointNode, freq as U32) as Int;
    function set_framerate(framerate as U8) as Void;
    function get_framerate() as U8;
    function register_hal(hal as HAL) as Void;
    function set_exec_mode(mode as ExecMode) as Void;

    /* NOTE: Only one of these two functions must be used in the main application
    * (tamalib.step() should be used only if tamalib.mainloop() does not fit the
    * main application execution flow).
    */
    function step() as Void;
    function mainloop() as Void;

    function set_button(btn, state);
    function set_speed(speed);
    function get_state();
    function refresh_hw();
    function reset();
    function add_bp(list, addr);
    function free_bp(list);
};

}
