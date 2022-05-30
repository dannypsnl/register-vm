const std = @import("std");
const mem = @import("std").mem;
const OpCode = @import("opcode.zig").OpCode;

pub const VirtualMachine = struct {
    const Self = @This();
    pc: usize,
    // internal
    registers: [30]u64,

    pub fn init() Self {
        return .{
            .pc = 0,
            .registers = [_]u64{0} ** 30,
        };
    }

    pub fn execute(self: *Self, code: []const u8) u64 {
        var reg = [10]u64{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
        while (true) {
            var inst = @intToEnum(OpCode, code[self.pc]);
            std.log.debug("inst {}", .{inst});
            self.pc += 1;
            switch (inst) {
                .NOP => {},
                .LOADI => {
                    const a = self.load_u8(code);
                    const r = self.load_u64(code);
                    reg[a] = r;
                    std.log.debug("x{} = int({})", .{ a, r });
                },
                .ADD => {
                    const a = self.load_u8(code);
                    const b = self.load_u8(code);
                    reg[a] += reg[b];
                    std.log.debug("x{} += x{}", .{ a, b });
                },
                .SUB => {
                    const a = self.load_u8(code);
                    const b = self.load_u8(code);
                    reg[a] -= reg[b];
                    std.log.debug("x{} -= x{}", .{ a, b });
                },
                .MUL => {
                    const a = self.load_u8(code);
                    const b = self.load_u8(code);
                    reg[a] *= reg[b];
                    std.log.debug("x{} *= x{}", .{ a, b });
                },
                .DIV => {
                    const a = self.load_u8(code);
                    const b = self.load_u8(code);
                    reg[a] /= reg[b];
                    std.log.debug("x{} /= x{}", .{ a, b });
                },
                .MOV => {
                    const a = self.load_u8(code);
                    const b = self.load_u8(code);
                    reg[a] = reg[b];
                    std.log.debug("x{} = x{}", .{ a, b });
                },
                .RET => {
                    const a = self.load_u8(code);
                    std.log.debug("ret x{}", .{a});
                    return reg[a];
                },
            }
        }
    }

    fn load_u8(self: *Self, b: []const u8) u8 {
        self.pc += 1;
        return b[self.pc - 1];
    }

    fn load_u64(self: *Self, b: []const u8) u64 {
        self.pc += 8;
        return mem.readIntSliceNative(u64, b[self.pc - 8 .. self.pc]);
    }
};
