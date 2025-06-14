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

using Toybox.Lang;

module tamalib {

const MEMORY_SIZE = 4096; // 4096 x 4 bits

const E0C6S46_SUPPORT = true;
const E0C6S48_SUPPORT = true;

/* E0C6S48 (compatible with E0C6S46) */
const MEM_RAM_ADDR      = 0x000;
const MEM_RAM_SIZE      = 0x300; // 768 x 4 bits of RAM
const MEM_DISPLAY1_ADDR = 0xE00;
const MEM_DISPLAY1_SIZE = 0x066; // 102 x 4 bits of RAM
const MEM_DISPLAY2_ADDR = 0xE80;
const MEM_DISPLAY2_SIZE = 0x066; // 102 x 4 bits of RAM
const MEM_IO_ADDR       = 0xF00;
const MEM_IO_SIZE       = 0x080;

const LOW_FOOTPRINT = false;

const MEM_BUFFER_SIZE = MEMORY_SIZE;

function SET_MEMORY(buffer as Memory, n as U12, v as U4) as Void { buffer[n] = v; }
function SET_RAM_MEMORY(buffer as Memory, n as U12, v as U4) as Void { SET_MEMORY(buffer, n, v); }
function SET_DISP1_MEMORY(buffer as Memory, n as U12, v as U4) as Void { SET_MEMORY(buffer, n, v); }
function SET_DISP2_MEMORY(buffer as Memory, n as U12, v as U4) as Void { SET_MEMORY(buffer, n, v); }
function SET_IO_MEMORY(buffer as Memory, n as U12, v as U4) as Void { SET_MEMORY(buffer, n, v); }

function GET_MEMORY(buffer as Memory, n as U12) as U4 { return buffer[n]; }
function GET_RAM_MEMORY(buffer as Memory, n as U12) as U4 { return GET_MEMORY(buffer, n); }
function GET_DISP1_MEMORY(buffer as Memory, n as U12) as U4 { return GET_MEMORY(buffer, n); }
function GET_DISP2_MEMORY(buffer as Memory, n as U12) as U4 { return GET_MEMORY(buffer, n); }
function GET_IO_MEMORY(buffer as Memory, n as U12) as U4 { return GET_MEMORY(buffer, n); }

class Breakpoint {
    var addr as U13;

    function initialize(addr as U13) {
        me.addr = addr;
    }
}

typedef Breakpoints as Lang.Array<Breakpoint>;

/* Pins (TODO: add other pins) */
enum Pin {
    PIN_K00 = 0x0,
    PIN_K01 = 0x1,
    PIN_K02 = 0x2,
    PIN_K03 = 0x3,
    PIN_K10 = 0x4,
    PIN_K11 = 0x5,
    PIN_K12 = 0x6,
    PIN_K13 = 0x7,
}

enum PinState {
    PIN_STATE_LOW  = 0,
    PIN_STATE_HIGH = 1,
}

enum IntSlot {
    INT_PROG_TIMER_SLOT  = 0,
    INT_SERIAL_SLOT      = 1,
    INT_K10_K13_SLOT     = 2,
    INT_K00_K03_SLOT     = 3,
    INT_STOPWATCH_SLOT   = 4,
    INT_CLOCK_TIMER_SLOT = 5,
    INT_SLOT_NUM,
}

class Interrupt {
    var factor_flag_reg as U4;
    var mask_reg as U4;
    var triggered as Bool;
    var vector as U8;

    function initialize(factor_flag_reg as U4, mask_reg as U4, triggered as Bool, vector as U8) {
        me.factor_flag_reg = factor_flag_reg;
        me.mask_reg = mask_reg;
        me.triggered = triggered;
        me.vector = vector;
    }
}

typedef Interrupts as Lang.Array<Interrupt>;

typedef State as interface {
    function get_pc() as U13;                        function set_pc(in as U13) as Void;
    function get_x() as U12;                         function set_x(in as U12) as Void;
    function get_y() as U12;                         function set_y(in as U12) as Void;
    function get_a() as U4;                          function set_a(in as U4) as Void;
    function get_b() as U4;                          function set_b(in as U4) as Void;
    function get_np() as U5;                         function set_np(in as U5) as Void;
    function get_sp() as U8;                         function set_sp(in as U8) as Void;
    function get_flags() as U4;                      function set_flags(in as U4) as Void;
    function get_tick_counter() as U32;              function set_tick_counter(in as U32) as Void;
    function get_clk_timer_2hz_timestamp() as U32;   function set_clk_timer_2hz_timestamp(in as U32) as Void;
    function get_clk_timer_4hz_timestamp() as U32;   function set_clk_timer_4hz_timestamp(in as U32) as Void;
    function get_clk_timer_8hz_timestamp() as U32;   function set_clk_timer_8hz_timestamp(in as U32) as Void;
    function get_clk_timer_16hz_timestamp() as U32;  function set_clk_timer_16hz_timestamp(in as U32) as Void;
    function get_clk_timer_32hz_timestamp() as U32;  function set_clk_timer_32hz_timestamp(in as U32) as Void;
    function get_clk_timer_64hz_timestamp() as U32;  function set_clk_timer_64hz_timestamp(in as U32) as Void;
    function get_clk_timer_128hz_timestamp() as U32; function set_clk_timer_128hz_timestamp(in as U32) as Void;
    function get_clk_timer_256hz_timestamp() as U32; function set_clk_timer_256hz_timestamp(in as U32) as Void;
    function get_prog_timer_timestamp() as U32;      function set_prog_timer_timestamp(in as U32) as Void;
    function get_prog_timer_enabled() as Bool;       function set_prog_timer_enabled(in as Bool) as Void;
    function get_prog_timer_data() as U8;            function set_prog_timer_data(in as U8) as Void;
    function get_prog_timer_rld() as U8;             function set_prog_timer_rld(in as U8) as Void;
    function get_call_depth() as U32;                function set_call_depth(in as U32) as Void;
    function get_interrupts() as Interrupts;         function set_interrupts(in as Interrupts) as Void;
    function get_cpu_halted() as Bool;               function set_cpu_halted(in as Bool) as Void;
    function get_memory() as Memory;                 function set_memory(in as Memory) as Void;
};

typedef CPU as interface {
    function add_bp(list as Breakpoints, addr as U13) as Void;
    function free_bp(list as Breakpoints) as Void;
    function set_speed(speed as U8) as Void;
    function get_state() as State;
    function get_depth() as U32;
    function set_input_pin(pin as Pin, state as PinState) as Void;
    function sync_ref_timestamp() as Void;
    function refresh_hw() as Void;
    function reset() as Void;
    function init(hal as HAL, hw as HW, program as Program, breakpoints as Breakpoints?, freq as U32) as Int;
    function release() as Void;
    function step() as Int;
};

}
