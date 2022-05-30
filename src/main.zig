const std = @import("std");
const mem = @import("std").mem;

const OpCode = enum(u8) {
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

fn load_u8(b: []const u8, pc: usize) u8 {
    return b[pc];
}
fn load_u64(b: []const u8, pc: usize) u64 {
    std.log.debug("slice: {any}", .{b[pc .. pc + 8]});
    return mem.readIntSliceNative(u64, b[pc .. pc + 8]);
}

fn execute(binary: []const u8) u64 {
    var pc: usize = 0;
    var reg = [10]u64{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    while (true) {
        var inst = @intToEnum(OpCode, binary[pc]);
        std.log.debug("inst {}", .{inst});
        pc += 1;
        switch (inst) {
            .NOP => {},
            .LOADI => {
                const a = load_u8(binary, pc);
                pc += 1;
                const r = load_u64(binary, pc);
                pc += 8;
                std.log.debug("x{} = int({})", .{ a, r });
                reg[a] = r;
            },
            .ADD => {
                const a = load_u8(binary, pc);
                pc += 1;
                const b = load_u8(binary, pc);
                pc += 1;
                reg[a] += reg[b];
                std.log.debug("x{} += x{}", .{ a, b });
            },
            .MOV => {
                const a = load_u8(binary, pc);
                pc += 1;
                const b = load_u8(binary, pc);
                pc += 1;
                reg[a] = reg[b];
                std.log.debug("x{} = x{}", .{ a, b });
            },
            .RET => {
                const a = load_u8(binary, pc);
                pc += 1;
                std.log.debug("ret x{}", .{a});
                return reg[a];
            },
        }
    }
}

pub fn main() anyerror!void {
    const code = [_]u8{
        // load x0 0x01
        @enumToInt(OpCode.LOADI), 0x00, 0x01, 0x00,                   0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        // load x1 0x02
        @enumToInt(OpCode.LOADI), 0x01, 0x02, 0x00,                   0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        // add x0 x1
        @enumToInt(OpCode.ADD),   0x00, 0x01,
        // return x0
        @enumToInt(OpCode.RET), 0x00,
    };
    const result = execute(&code);
    std.log.debug("result {}", .{result});
}

test "basic test" {
    try std.testing.expectEqual(OpCode.LOADI, @intToEnum(OpCode, 1));
}
