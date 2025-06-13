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

enum LogLevel {
    LOG_ERROR  = (0x1 << 0),
    LOG_INFO   = (0x1 << 1),
    LOG_MEMORY = (0x1 << 2),
    LOG_CPU    = (0x1 << 3),
    LOG_INT    = (0x1 << 4),
}

typedef HAL as interface {
    /* Memory allocation functions
     * NOTE: Needed only if breakpoints support is required.
     */
    function malloc(size as U32) as Object?;
    function free(ptr as Object?) as Void;

    /* What to do if the CPU has halted
     */
    function halt() as Void;

    /* Log related function
     * NOTE: Needed only if log messages are required.
     */
    function is_log_enabled(level as LogLevel) as Bool;
    function log(level as LogLevel, buff as String, args as Array<Object>) as Void;

    /* Clock related functions
     * NOTE: Timestamps granularity is configured with tamalib_init(), an accuracy
     * of ~30 us (1/32768) is required for a cycle accurate emulation.
     */
    function sleep_until(ts as Timestamp) as Void;
    function get_timestamp() as Timestamp;

    /* Screen related functions
     * NOTE: In case of direct hardware access to pixels, the set_XXXX() functions
     * (called for each pixel/icon update) can directly drive them, otherwise they
     * should just store the data in a buffer and let update_screen() do the actual
     * rendering (at 30 fps).
     */
    function update_screen() as Void;
    function set_lcd_matrix(x as U8, y as U8, val as Bool) as Void;
    function set_lcd_icon(icon as U8, val as Bool) as Void;

    /* Sound related functions
     * NOTE: set_frequency() changes the output frequency of the sound in dHz, while
     * play_frequency() decides whether the sound should be heard or not.
     */
    function set_frequency(freq as U32) as Void;
    function play_frequency(en as Bool) as Void;

    /* Event handler from the main app (if any)
     * NOTE: This function usually handles button related events, states loading/saving ...
     */
    function handler() as Int;
};

}
