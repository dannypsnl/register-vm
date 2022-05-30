pub const OpCode = enum(u8) {
    // no operation
    NOP,
    // reg[a] = immediate_int64
    LOADI,
    // reg[a] += reg[b]
    ADD,
    // reg[a] = reg[b]
    MOV,
    // return reg[a]
    RET,
};
