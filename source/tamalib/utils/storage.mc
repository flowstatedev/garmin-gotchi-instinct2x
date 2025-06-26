using Toybox.Application as app;
using Toybox.System as sys;
using Toybox.Lang;

module tamalib {

const STORAGE_KEY_PC                        = "pc";
const STORAGE_KEY_X                         = "x";
const STORAGE_KEY_Y                         = "y";
const STORAGE_KEY_A                         = "a";
const STORAGE_KEY_B                         = "b";
const STORAGE_KEY_NP                        = "np";
const STORAGE_KEY_SP                        = "sp";
const STORAGE_KEY_FLAGS                     = "flags";
const STORAGE_KEY_TICK_COUNTER              = "tick_counter";
const STORAGE_KEY_CLK_TIMER_2HZ_TIMESTAMP   = "clk_timer_2hz_timestamp";
const STORAGE_KEY_CLK_TIMER_4HZ_TIMESTAMP   = "clk_timer_4hz_timestamp";
const STORAGE_KEY_CLK_TIMER_8HZ_TIMESTAMP   = "clk_timer_8hz_timestamp";
const STORAGE_KEY_CLK_TIMER_16HZ_TIMESTAMP  = "clk_timer_16hz_timestamp";
const STORAGE_KEY_CLK_TIMER_32HZ_TIMESTAMP  = "clk_timer_32hz_timestamp";
const STORAGE_KEY_CLK_TIMER_64HZ_TIMESTAMP  = "clk_timer_64hz_timestamp";
const STORAGE_KEY_CLK_TIMER_128HZ_TIMESTAMP = "clk_timer_128hz_timestamp";
const STORAGE_KEY_CLK_TIMER_256HZ_TIMESTAMP = "clk_timer_256hz_timestamp";
const STORAGE_KEY_PROG_TIMER_TIMESTAMP      = "prog_timer_timestamp";
const STORAGE_KEY_PROG_TIMER_ENABLED        = "prog_timer_enabled";
const STORAGE_KEY_PROG_TIMER_DATA           = "prog_timer_data";
const STORAGE_KEY_PROG_TIMER_RLD            = "prog_timer_rld";
const STORAGE_KEY_CALL_DEPTH                = "call_depth";
const STORAGE_KEY_INTERRUPTS                = "interrupts";
const STORAGE_KEY_MEMORY_RAM                = "memory_ram";
const STORAGE_KEY_MEMORY_IO                 = "memory_io";
const STORAGE_KEY_STATE_SAVED               = "state_saved";

function save_state(state as CPUState) as Void {
    _set_saved_state_flag(false);

    _save_state_variables(state);
    _save_state_interrupts(state);
    _save_state_memory_ram(state);
    _save_state_memory_io(state);

    _set_saved_state_flag(true);
}

function load_state(state as CPUState) as Void {
    if (!_get_saved_state_flag()) { return; }

    _load_state_variables(state);
    _load_state_interrupts(state);
    _load_state_memory_ram(state);
    _load_state_memory_io(state);
}

function _set_saved_state_flag(flag as Bool) as Void {
    app.Storage.setValue(STORAGE_KEY_STATE_SAVED, flag);
}

function _get_saved_state_flag() as Bool {
    var flag = app.Storage.getValue(STORAGE_KEY_STATE_SAVED);
    if (flag == null) { return false; }
    return flag as Bool;
}

function _save_state_variables(state as CPUState) as Void {
    app.Storage.setValue(STORAGE_KEY_PC, state.get_pc());
    app.Storage.setValue(STORAGE_KEY_X, state.get_x());
    app.Storage.setValue(STORAGE_KEY_Y, state.get_y());
    app.Storage.setValue(STORAGE_KEY_A, state.get_a());
    app.Storage.setValue(STORAGE_KEY_B, state.get_b());
    app.Storage.setValue(STORAGE_KEY_NP, state.get_np());
    app.Storage.setValue(STORAGE_KEY_SP, state.get_sp());
    app.Storage.setValue(STORAGE_KEY_FLAGS, state.get_flags());
    app.Storage.setValue(STORAGE_KEY_TICK_COUNTER, state.get_tick_counter());
    app.Storage.setValue(STORAGE_KEY_CLK_TIMER_2HZ_TIMESTAMP, state.get_clk_timer_2hz_timestamp());
    app.Storage.setValue(STORAGE_KEY_CLK_TIMER_4HZ_TIMESTAMP, state.get_clk_timer_4hz_timestamp());
    app.Storage.setValue(STORAGE_KEY_CLK_TIMER_8HZ_TIMESTAMP, state.get_clk_timer_8hz_timestamp());
    app.Storage.setValue(STORAGE_KEY_CLK_TIMER_16HZ_TIMESTAMP, state.get_clk_timer_16hz_timestamp());
    app.Storage.setValue(STORAGE_KEY_CLK_TIMER_32HZ_TIMESTAMP, state.get_clk_timer_32hz_timestamp());
    app.Storage.setValue(STORAGE_KEY_CLK_TIMER_64HZ_TIMESTAMP, state.get_clk_timer_64hz_timestamp());
    app.Storage.setValue(STORAGE_KEY_CLK_TIMER_128HZ_TIMESTAMP, state.get_clk_timer_128hz_timestamp());
    app.Storage.setValue(STORAGE_KEY_CLK_TIMER_256HZ_TIMESTAMP, state.get_clk_timer_256hz_timestamp());
    app.Storage.setValue(STORAGE_KEY_PROG_TIMER_TIMESTAMP, state.get_prog_timer_timestamp());
    app.Storage.setValue(STORAGE_KEY_PROG_TIMER_ENABLED, state.get_prog_timer_enabled());
    app.Storage.setValue(STORAGE_KEY_PROG_TIMER_DATA, state.get_prog_timer_data());
    app.Storage.setValue(STORAGE_KEY_PROG_TIMER_RLD, state.get_prog_timer_rld());
    app.Storage.setValue(STORAGE_KEY_CALL_DEPTH, state.get_call_depth());
}

function _save_state_interrupts(state as CPUState) as Void {
    var interrupts = state.get_interrupts();
    var encodings = new [INT_SLOT_NUM];
    for (var i = 0; i < INT_SLOT_NUM; i++) {
        var encoding = 0x0000 as U32;
        encoding = (encoding << 8) | (interrupts[i].factor_flag_reg & 0xFF);
        encoding = (encoding << 8) | (interrupts[i].mask_reg & 0xFF);
        encoding = (encoding << 8) | (int(interrupts[i].triggered) & 0xFF);
        encoding = (encoding << 8) | (interrupts[i].vector & 0xFF);
        encodings.add(encoding);
    }
    app.Storage.setValue(STORAGE_KEY_INTERRUPTS, encodings as app.PropertyValueType);
}

function _save_state_memory_ram(state as CPUState) as Void {
    _save_state_memory(state, STORAGE_KEY_MEMORY_RAM, MEM_RAM_ADDR, MEM_RAM_SIZE);
}

function _save_state_memory_io(state as CPUState) as Void {
    _save_state_memory(state, STORAGE_KEY_MEMORY_IO, MEM_IO_ADDR, MEM_IO_SIZE);
}

function _save_state_memory(state as CPUState, storage_key as String, mem_addr as U32, mem_size as U32) as Void {
    var memory = state.get_memory();
    var memory_encoded = new [mem_size / 8];
    for (var i = 0; i < mem_size; i++) {
        var encoding = 0x0000 as U32;
        for (var j = 0; j < 8; j++) {
            encoding = (encoding << 4) | (memory[i + j + mem_addr] & 0xF);
        }
        memory_encoded[i / 8] = encoding;
    }
    app.Storage.setValue(storage_key, memory_encoded as app.PropertyValueType);
}

function _load_state_variables(state as CPUState) as Void {
    state.set_pc(app.Storage.getValue(STORAGE_KEY_PC) as U13);
    state.set_x(app.Storage.getValue(STORAGE_KEY_X) as U12);
    state.set_y(app.Storage.getValue(STORAGE_KEY_Y) as U12);
    state.set_a(app.Storage.getValue(STORAGE_KEY_A) as U4);
    state.set_b(app.Storage.getValue(STORAGE_KEY_B) as U4);
    state.set_np(app.Storage.getValue(STORAGE_KEY_NP) as U5);
    state.set_sp(app.Storage.getValue(STORAGE_KEY_SP) as U8);
    state.set_flags(app.Storage.getValue(STORAGE_KEY_FLAGS) as U4);
    state.set_tick_counter(app.Storage.getValue(STORAGE_KEY_TICK_COUNTER) as U32);
    state.set_clk_timer_2hz_timestamp(app.Storage.getValue(STORAGE_KEY_CLK_TIMER_2HZ_TIMESTAMP) as U32);
    state.set_clk_timer_4hz_timestamp(app.Storage.getValue(STORAGE_KEY_CLK_TIMER_4HZ_TIMESTAMP) as U32);
    state.set_clk_timer_8hz_timestamp(app.Storage.getValue(STORAGE_KEY_CLK_TIMER_8HZ_TIMESTAMP) as U32);
    state.set_clk_timer_16hz_timestamp(app.Storage.getValue(STORAGE_KEY_CLK_TIMER_16HZ_TIMESTAMP) as U32);
    state.set_clk_timer_32hz_timestamp(app.Storage.getValue(STORAGE_KEY_CLK_TIMER_32HZ_TIMESTAMP) as U32);
    state.set_clk_timer_64hz_timestamp(app.Storage.getValue(STORAGE_KEY_CLK_TIMER_64HZ_TIMESTAMP) as U32);
    state.set_clk_timer_128hz_timestamp(app.Storage.getValue(STORAGE_KEY_CLK_TIMER_128HZ_TIMESTAMP) as U32);
    state.set_clk_timer_256hz_timestamp(app.Storage.getValue(STORAGE_KEY_CLK_TIMER_256HZ_TIMESTAMP) as U32);
    state.set_prog_timer_timestamp(app.Storage.getValue(STORAGE_KEY_PROG_TIMER_TIMESTAMP) as U32);
    state.set_prog_timer_enabled(app.Storage.getValue(STORAGE_KEY_PROG_TIMER_ENABLED) as Bool);
    state.set_prog_timer_data(app.Storage.getValue(STORAGE_KEY_PROG_TIMER_DATA) as U8);
    state.set_prog_timer_rld(app.Storage.getValue(STORAGE_KEY_PROG_TIMER_RLD) as U8);
    state.set_call_depth(app.Storage.getValue(STORAGE_KEY_CALL_DEPTH) as U32);
}

function _load_state_interrupts(state as CPUState) as Void {
    var interrupts = state.get_interrupts();
    var encodings = app.Storage.getValue(STORAGE_KEY_INTERRUPTS) as Lang.Array<U32>;
    for (var i = 0; i < INT_SLOT_NUM; i++) {
        interrupts[i].factor_flag_reg = (encodings[i] >> 24) & 0xFF;
        interrupts[i].mask_reg = (encodings[i] >> 16) & 0xFF;
        interrupts[i].triggered = bool((encodings[i] >> 8) & 0xFF);
        interrupts[i].vector = (encodings[i] >> 0) & 0xFF;
    }
}

function _load_state_memory_ram(state as CPUState) as Void {
    _load_state_memory(state, STORAGE_KEY_MEMORY_RAM, MEM_RAM_ADDR, MEM_RAM_SIZE);
}

function _load_state_memory_io(state as CPUState) as Void {
    _load_state_memory(state, STORAGE_KEY_MEMORY_IO, MEM_IO_ADDR, MEM_IO_SIZE);
}

function _load_state_memory(state as CPUState, storage_key as String, mem_addr as U32, mem_size as U32) as Void {
    var memory = state.get_memory();
    var memory_encoded = app.Storage.getValue(storage_key) as Lang.Array<U32>;
    for (var i = 0; i < mem_size; i += 8) {
        var encoding = memory_encoded[i / 8];
        for (var j = 0; j < 8; j++) {
            memory[i + j + mem_addr] = (encoding >> ((7 - j) * 4)) & 0xF;
        }
    }
}

}
