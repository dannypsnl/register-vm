const std = @import("std");
const VirtualMachine = @import("vm.zig").VirtualMachine;
const OpCode = @import("opcode.zig").OpCode;

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
    var vm = VirtualMachine.init();
    const result = vm.execute(&code);
    std.log.debug("result {}", .{result});
}
