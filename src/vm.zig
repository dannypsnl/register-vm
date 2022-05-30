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
        while (true) {
            var inst = @intToEnum(OpCode, code[self.pc]);
            std.log.debug("inst {}", .{inst});
            self.pc += 1;
            switch (inst) {
                .NOP => {},
                .LOADI => {
                    const a = self.load_u8(code);
                    const r = self.load_u64(code);
                    self.registers[a] = r;
                    std.log.debug("x{} = int({})", .{ a, r });
                },
                .ADD => {
                    const a = self.load_u8(code);
                    const b = self.load_u8(code);
                    self.registers[a] += self.registers[b];
                    std.log.debug("x{} += x{}", .{ a, b });
                },
                .SUB => {
                    const a = self.load_u8(code);
                    const b = self.load_u8(code);
                    self.registers[a] -= self.registers[b];
                    std.log.debug("x{} -= x{}", .{ a, b });
                },
                .MUL => {
                    const a = self.load_u8(code);
                    const b = self.load_u8(code);
                    self.registers[a] *= self.registers[b];
                    std.log.debug("x{} *= x{}", .{ a, b });
                },
                .DIV => {
                    const a = self.load_u8(code);
                    const b = self.load_u8(code);
                    self.registers[a] /= self.registers[b];
                    std.log.debug("x{} /= x{}", .{ a, b });
                },
                .EQ => {
                    const a = self.load_u8(code);
                    const b = self.load_u8(code);
                    self.registers[a] = @boolToInt(self.registers[a] == self.registers[b]);
                    std.log.debug("x{} = x{} == x{}", .{ a, a, b });
                },
                .LT => {
                    const a = self.load_u8(code);
                    const b = self.load_u8(code);
                    self.registers[a] = @boolToInt(self.registers[a] < self.registers[b]);
                    std.log.debug("x{} = x{} < x{}", .{ a, a, b });
                },
                .LE => {
                    const a = self.load_u8(code);
                    const b = self.load_u8(code);
                    self.registers[a] = @boolToInt(self.registers[a] <= self.registers[b]);
                    std.log.debug("x{} = x{} <= x{}", .{ a, a, b });
                },
                .GT => {
                    const a = self.load_u8(code);
                    const b = self.load_u8(code);
                    self.registers[a] = @boolToInt(self.registers[a] > self.registers[b]);
                    std.log.debug("x{} = x{} > x{}", .{ a, a, b });
                },
                .GE => {
                    const a = self.load_u8(code);
                    const b = self.load_u8(code);
                    self.registers[a] = @boolToInt(self.registers[a] >= self.registers[b]);
                    std.log.debug("x{} = x{} >= x{}", .{ a, a, b });
                },
                .MOV => {
                    const a = self.load_u8(code);
                    const b = self.load_u8(code);
                    self.registers[a] = self.registers[b];
                    std.log.debug("x{} = x{}", .{ a, b });
                },
                .RET => {
                    const a = self.load_u8(code);
                    std.log.debug("ret x{}", .{a});
                    return self.registers[a];
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

test "arithmetic" {
    const code = [_]u8{
        // load x0 0x01
        @enumToInt(OpCode.LOADI), 0x00, 0x01,                   0x00,                   0x00, 0x00, 0x00,                     0x00, 0x00, 0x00,
        // load x1 0x02
        @enumToInt(OpCode.LOADI), 0x01, 0x02,                   0x00,                   0x00, 0x00, 0x00,                     0x00, 0x00, 0x00,
        // add x0 x1
        @enumToInt(OpCode.ADD),   0x00, 0x01,
        // mul x0 x0
                          @enumToInt(OpCode.MUL), 0x00, 0x00,
        // load x1 0x03
        @enumToInt(OpCode.LOADI), 0x01, 0x03, 0x00,
        0x00,                     0x00, 0x00,                   0x00,                   0x00, 0x00,
        // div x0 x1
        @enumToInt(OpCode.DIV),   0x00, 0x01,
        // load x1 0x01
        @enumToInt(OpCode.LOADI),
        0x01,                     0x01, 0x00,                   0x00,                   0x00, 0x00, 0x00,                     0x00, 0x00,
        // sub x0 x1
        @enumToInt(OpCode.SUB),
        0x00,                     0x01,
        // return x0
        @enumToInt(OpCode.RET), 0x00,
    };
    var vm = VirtualMachine.init();
    try std.testing.expectEqual(vm.execute(&code), 2);
}

test "logic equal" {
    const code = [_]u8{
        // load x0 0x01
        @enumToInt(OpCode.LOADI), 0x00, 0x01, 0x00,                   0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        // load x1 0x02
        @enumToInt(OpCode.LOADI), 0x01, 0x02, 0x00,                   0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        // eq x0 x1
        @enumToInt(OpCode.EQ),    0x00, 0x01,
        // return x0
        @enumToInt(OpCode.RET), 0x00,
    };
    var vm = VirtualMachine.init();
    try std.testing.expectEqual(vm.execute(&code), 0);
}

test "logic less equal" {
    const code = [_]u8{
        // load x0 0x01
        @enumToInt(OpCode.LOADI), 0x00, 0x01, 0x00,                   0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        // load x1 0x02
        @enumToInt(OpCode.LOADI), 0x01, 0x02, 0x00,                   0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        // eq x0 x1
        @enumToInt(OpCode.LE),    0x00, 0x01,
        // return x0
        @enumToInt(OpCode.RET), 0x00,
    };
    var vm = VirtualMachine.init();
    try std.testing.expectEqual(vm.execute(&code), 1);
}
