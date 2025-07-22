using Toybox.Application as app;
import Toybox.Lang;

module tamalib {

const STORAGE_KEY_PC                        = 0; // "pc";
const STORAGE_KEY_X                         = 1; // "x";
const STORAGE_KEY_Y                         = 2; // "y";
const STORAGE_KEY_A                         = 3; // "a";
const STORAGE_KEY_B                         = 4; // "b";
const STORAGE_KEY_NP                        = 5; // "np";
const STORAGE_KEY_SP                        = 6; // "sp";
const STORAGE_KEY_FLAGS                     = 7; // "flags";
const STORAGE_KEY_TICK_COUNTER              = 8; // "tick_counter";
const STORAGE_KEY_CLK_TIMER_2HZ_TIMESTAMP   = 9; // "clk_timer_2hz_timestamp";
const STORAGE_KEY_CLK_TIMER_4HZ_TIMESTAMP   = 10; // "clk_timer_4hz_timestamp";
const STORAGE_KEY_CLK_TIMER_8HZ_TIMESTAMP   = 11; // "clk_timer_8hz_timestamp";
const STORAGE_KEY_CLK_TIMER_16HZ_TIMESTAMP  = 12; // "clk_timer_16hz_timestamp";
const STORAGE_KEY_CLK_TIMER_32HZ_TIMESTAMP  = 13; // "clk_timer_32hz_timestamp";
const STORAGE_KEY_CLK_TIMER_64HZ_TIMESTAMP  = 14; // "clk_timer_64hz_timestamp";
const STORAGE_KEY_CLK_TIMER_128HZ_TIMESTAMP = 15; // "clk_timer_128hz_timestamp";
const STORAGE_KEY_CLK_TIMER_256HZ_TIMESTAMP = 16; // "clk_timer_256hz_timestamp";
const STORAGE_KEY_PROG_TIMER_TIMESTAMP      = 17; // "prog_timer_timestamp";
const STORAGE_KEY_PROG_TIMER_ENABLED        = 18; // "prog_timer_enabled";
const STORAGE_KEY_PROG_TIMER_DATA           = 19; // "prog_timer_data";
const STORAGE_KEY_PROG_TIMER_RLD            = 20; // "prog_timer_rld";
const STORAGE_KEY_CALL_DEPTH                = 21; // "call_depth";
const STORAGE_KEY_INTERRUPTS                = 22; // "interrupts";
const STORAGE_KEY_MEMORY_RAM                = 23; // "memory_ram";
const STORAGE_KEY_MEMORY_IO                 = 24; // "memory_io";
const STORAGE_KEY_STATE_SAVED               = 25; // "state_saved";

typedef StorageKeyType as Number;

function save_state(state as CPUState) as Void {
    set_state_saved(false);

    save_state_variables(state);
    save_state_interrupts(state);
    save_state_memory_ram(state);
    save_state_memory_io(state);

    set_state_saved(true);
}

function load_state(state as CPUState) as Void {
    if (!is_state_saved()) { return; }

    load_state_variables(state);
    load_state_interrupts(state);
    load_state_memory_ram(state);
    load_state_memory_io(state);
}

function set_state_saved(flag as Bool) as Void {
    app.Storage.setValue(STORAGE_KEY_STATE_SAVED, flag);
}

function is_state_saved() as Bool {
    var flag = app.Storage.getValue(STORAGE_KEY_STATE_SAVED);
    if (flag == null) { return false; }
    return flag as Bool;
}

function save_state_variables(state as CPUState) as Void {
    app.Storage.setValue(STORAGE_KEY_PC,                        state.get_pc()                       );
    app.Storage.setValue(STORAGE_KEY_X,                         state.get_x()                        );
    app.Storage.setValue(STORAGE_KEY_Y,                         state.get_y()                        );
    app.Storage.setValue(STORAGE_KEY_A,                         state.get_a()                        );
    app.Storage.setValue(STORAGE_KEY_B,                         state.get_b()                        );
    app.Storage.setValue(STORAGE_KEY_NP,                        state.get_np()                       );
    app.Storage.setValue(STORAGE_KEY_SP,                        state.get_sp()                       );
    app.Storage.setValue(STORAGE_KEY_FLAGS,                     state.get_flags()                    );
    app.Storage.setValue(STORAGE_KEY_TICK_COUNTER,              state.get_tick_counter()             );
    app.Storage.setValue(STORAGE_KEY_CLK_TIMER_2HZ_TIMESTAMP,   state.get_clk_timer_2hz_timestamp()  );
    app.Storage.setValue(STORAGE_KEY_CLK_TIMER_4HZ_TIMESTAMP,   state.get_clk_timer_4hz_timestamp()  );
    app.Storage.setValue(STORAGE_KEY_CLK_TIMER_8HZ_TIMESTAMP,   state.get_clk_timer_8hz_timestamp()  );
    app.Storage.setValue(STORAGE_KEY_CLK_TIMER_16HZ_TIMESTAMP,  state.get_clk_timer_16hz_timestamp() );
    app.Storage.setValue(STORAGE_KEY_CLK_TIMER_32HZ_TIMESTAMP,  state.get_clk_timer_32hz_timestamp() );
    app.Storage.setValue(STORAGE_KEY_CLK_TIMER_64HZ_TIMESTAMP,  state.get_clk_timer_64hz_timestamp() );
    app.Storage.setValue(STORAGE_KEY_CLK_TIMER_128HZ_TIMESTAMP, state.get_clk_timer_128hz_timestamp());
    app.Storage.setValue(STORAGE_KEY_CLK_TIMER_256HZ_TIMESTAMP, state.get_clk_timer_256hz_timestamp());
    app.Storage.setValue(STORAGE_KEY_PROG_TIMER_TIMESTAMP,      state.get_prog_timer_timestamp()     );
    app.Storage.setValue(STORAGE_KEY_PROG_TIMER_ENABLED,        state.get_prog_timer_enabled()       );
    app.Storage.setValue(STORAGE_KEY_PROG_TIMER_DATA,           state.get_prog_timer_data()          );
    app.Storage.setValue(STORAGE_KEY_PROG_TIMER_RLD,            state.get_prog_timer_rld()           );
    app.Storage.setValue(STORAGE_KEY_CALL_DEPTH,                state.get_call_depth()               );
}

function save_state_interrupts(state as CPUState) as Void {
    var interrupts = state.get_interrupts();
    var encodings = new [INT_SLOT_NUM];
    for (var i = 0; i < INT_SLOT_NUM; i++) {
        encodings[i] = (0x0000 as U32
            |     (interrupts[i].factor_flag_reg << 24)
            |     (interrupts[i].mask_reg        << 16)
            |     (interrupts[i].triggered       <<  8)
            |     (interrupts[i].vector          <<  0)
        );
    }
    app.Storage.setValue(STORAGE_KEY_INTERRUPTS, encodings as app.PropertyValueType);
}

function save_state_memory_ram(state as CPUState) as Void {
    save_state_memory(state, STORAGE_KEY_MEMORY_RAM, MEM_RAM_ADDR, MEM_RAM_SIZE);
}

function save_state_memory_io(state as CPUState) as Void {
    save_state_memory(state, STORAGE_KEY_MEMORY_IO, MEM_IO_ADDR, MEM_IO_SIZE);
}

function save_state_memory(state as CPUState, storage_key as StorageKeyType, mem_addr as U32, mem_size as U32) as Void {
    var memory = state.get_memory();
    var encodings = new [mem_size / 8];
    for (var i = 0; i < encodings.size(); i++) {
        var addr = (mem_addr / 2) + (i * 4);
        encodings[i] = (0x0000 as U32
            | (memory[addr + 0] << 24)
            | (memory[addr + 1] << 16)
            | (memory[addr + 2] <<  8)
            | (memory[addr + 3] <<  0)
        );
    }
    app.Storage.setValue(storage_key, encodings as app.PropertyValueType);
}

function load_state_variables(state as CPUState) as Void {
    state.set_pc(                       app.Storage.getValue(STORAGE_KEY_PC)                        as U13 );
    state.set_x(                        app.Storage.getValue(STORAGE_KEY_X)                         as U12 );
    state.set_y(                        app.Storage.getValue(STORAGE_KEY_Y)                         as U12 );
    state.set_a(                        app.Storage.getValue(STORAGE_KEY_A)                         as U4  );
    state.set_b(                        app.Storage.getValue(STORAGE_KEY_B)                         as U4  );
    state.set_np(                       app.Storage.getValue(STORAGE_KEY_NP)                        as U5  );
    state.set_sp(                       app.Storage.getValue(STORAGE_KEY_SP)                        as U8  );
    state.set_flags(                    app.Storage.getValue(STORAGE_KEY_FLAGS)                     as U4  );
    state.set_tick_counter(             app.Storage.getValue(STORAGE_KEY_TICK_COUNTER)              as U32 );
    state.set_clk_timer_2hz_timestamp(  app.Storage.getValue(STORAGE_KEY_CLK_TIMER_2HZ_TIMESTAMP)   as U32 );
    state.set_clk_timer_4hz_timestamp(  app.Storage.getValue(STORAGE_KEY_CLK_TIMER_4HZ_TIMESTAMP)   as U32 );
    state.set_clk_timer_8hz_timestamp(  app.Storage.getValue(STORAGE_KEY_CLK_TIMER_8HZ_TIMESTAMP)   as U32 );
    state.set_clk_timer_16hz_timestamp( app.Storage.getValue(STORAGE_KEY_CLK_TIMER_16HZ_TIMESTAMP)  as U32 );
    state.set_clk_timer_32hz_timestamp( app.Storage.getValue(STORAGE_KEY_CLK_TIMER_32HZ_TIMESTAMP)  as U32 );
    state.set_clk_timer_64hz_timestamp( app.Storage.getValue(STORAGE_KEY_CLK_TIMER_64HZ_TIMESTAMP)  as U32 );
    state.set_clk_timer_128hz_timestamp(app.Storage.getValue(STORAGE_KEY_CLK_TIMER_128HZ_TIMESTAMP) as U32 );
    state.set_clk_timer_256hz_timestamp(app.Storage.getValue(STORAGE_KEY_CLK_TIMER_256HZ_TIMESTAMP) as U32 );
    state.set_prog_timer_timestamp(     app.Storage.getValue(STORAGE_KEY_PROG_TIMER_TIMESTAMP)      as U32 );
    state.set_prog_timer_enabled(       app.Storage.getValue(STORAGE_KEY_PROG_TIMER_ENABLED)        as Bool);
    state.set_prog_timer_data(          app.Storage.getValue(STORAGE_KEY_PROG_TIMER_DATA)           as U8  );
    state.set_prog_timer_rld(           app.Storage.getValue(STORAGE_KEY_PROG_TIMER_RLD)            as U8  );
    state.set_call_depth(               app.Storage.getValue(STORAGE_KEY_CALL_DEPTH)                as U32 );
}

function load_state_interrupts(state as CPUState) as Void {
    var interrupts = state.get_interrupts();
    var encodings = app.Storage.getValue(STORAGE_KEY_INTERRUPTS) as Array<U32>;
    for (var i = 0; i < INT_SLOT_NUM; i++) {
        interrupts[i].factor_flag_reg = ((encodings[i] >> 24) & 0x0F);
        interrupts[i].mask_reg =        ((encodings[i] >> 16) & 0x0F);
        interrupts[i].triggered =       ((encodings[i] >>  8) & 0x01);
        interrupts[i].vector =          ((encodings[i] >>  0) & 0xFF);
    }
}

function load_state_memory_ram(state as CPUState) as Void {
    load_state_memory(state, STORAGE_KEY_MEMORY_RAM, MEM_RAM_ADDR, MEM_RAM_SIZE);
}

function load_state_memory_io(state as CPUState) as Void {
    load_state_memory(state, STORAGE_KEY_MEMORY_IO, MEM_IO_ADDR, MEM_IO_SIZE);
}

function load_state_memory(state as CPUState, storage_key as StorageKeyType, mem_addr as U32, mem_size as U32) as Void {
    var memory = state.get_memory();
    var encodings = app.Storage.getValue(storage_key) as Array<U32>;
    for (var i = 0; i < mem_size / 8; i++) {
        var addr = (mem_addr / 2) + (i * 4);
        memory[addr + 0] = (encodings[i] >> 24) & 0xFF;
        memory[addr + 1] = (encodings[i] >> 16) & 0xFF;
        memory[addr + 2] = (encodings[i] >>  8) & 0xFF;
        memory[addr + 3] = (encodings[i] >>  0) & 0xFF;
    }
}

}
