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

class Tamalib_impl {

    const DEFAULT_FRAMERATE = 30; // fps

    var exec_mode as ExecMode = EXEC_MODE_RUN;
    var step_depth as U32 = 0;
    var screen_ts as Timestamp = 0;
    var ts_freq as U32?;
    var g_framerate as U8 = DEFAULT_FRAMERATE;
    var g_hal as HAL;
    var g_cpu as CPU;
    var g_hw as HW;

    function initialize(log_level_flags as Number) {
        g_hal = new HAL_impl(log_level_flags);
        g_cpu = new CPU_impl();
        g_hw = new HW_impl();
    }

    function init(program as Program, breakpoints as Array<Breakpoint>, freq as U32) as Int {
        var res = 0;

        res |= g_cpu.init(g_hal, g_hw, program, breakpoints, freq);
        res |= g_hw.init(g_hal, g_cpu);

        ts_freq = freq;

        return res;
    }

    function release() as Void {
        g_hw.release();
        g_cpu.release();
    }

    function set_framerate(framerate as U8) as Void {
        g_framerate = framerate;
    }

    function get_framerate() as U8 {
        return g_framerate;
    }

    function register_hal(hal as HAL) as Void {
        g_hal = hal;
    }

    function set_exec_mode(mode as ExecMode) as Void {
        exec_mode = mode;
        step_depth = g_cpu.get_depth();
        g_cpu.sync_ref_timestamp();
    }

    function step() as Void {
        if (exec_mode == EXEC_MODE_PAUSE) {
            return;
        }

        if (g_cpu.step()) {
            exec_mode = EXEC_MODE_PAUSE;
            step_depth = g_cpu.get_depth();
        } else {
            switch (exec_mode) {
                case EXEC_MODE_PAUSE:
                case EXEC_MODE_RUN:
                    break;

                case EXEC_MODE_STEP:
                    exec_mode = EXEC_MODE_PAUSE;
                    break;

                case EXEC_MODE_NEXT:
                    if (g_cpu.get_depth() <= step_depth) {
                        exec_mode = EXEC_MODE_PAUSE;
                        step_depth = g_cpu.get_depth();
                    }
                    break;

                case EXEC_MODE_TO_CALL:
                    if (g_cpu.get_depth() > step_depth) {
                        exec_mode = EXEC_MODE_PAUSE;
                        step_depth = g_cpu.get_depth();
                    }
                    break;

                case EXEC_MODE_TO_RET:
                    if (g_cpu.get_depth() < step_depth) {
                        exec_mode = EXEC_MODE_PAUSE;
                        step_depth = g_cpu.get_depth();
                    }
                    break;
            }
        }
    }

    function mainloop() as Void {
        var ts;

        while (!g_hal.handler()) {
            step();

            /* Update the screen @ g_framerate fps */
            ts = g_hal.get_timestamp();
            if (ts - screen_ts >= ts_freq/g_framerate) {
                screen_ts = ts;
                g_hal.update_screen();
            }
        }
    }

    function set_button(btn, state) {
        g_hw.set_button(btn, state);
    }

    function set_speed(speed) {
        g_cpu.set_speed(speed);
    }

    function get_state() {
        return g_cpu.get_state();
    }

    function refresh_hw() {
        g_cpu.refresh_hw();
    }

    function reset() {
        g_cpu.reset();
    }

    function add_bp(list, addr) {
        g_cpu.add_bp(list, addr);
    }

    function free_bp(list) {
        g_cpu.free_bp(list);
    }

}

}
