pub const OpCode = enum(u8) {
    // no operation
    NOP,
    // reg[a] = immediate_int64
    LOADI,
    // reg[a] (+-*/)= reg[b]
    ADD,
    SUB,
    MUL,
    DIV,
    // reg[a] compare reg[b]
    EQ,
    LT,
    LE,
    GT,
    GE,
    // reg[a] = reg[b]
    MOV,
    // return reg[a]
    RET,
};
