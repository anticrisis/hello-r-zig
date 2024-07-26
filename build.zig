const std = @import("std");

pub fn build(b: *std.Build) !void {
    const libdir = b.addWriteFiles();

    const src = b.addWriteFiles();
    _ = src.addCopyDirectory(b.path("src/hello"), "", .{});

    const build_r = b.addSystemCommand(&.{"R"});
    build_r.addArgs(&.{ "CMD", "INSTALL", "-l" });
    build_r.addDirectoryArg(libdir.getDirectory());
    build_r.addDirectoryArg(src.getDirectory());

    const inst = b.addInstallDirectory(.{
        .source_dir = libdir.getDirectory().path(b, "hello"),
        .install_dir = .lib,
        .install_subdir = "hello",
    });
    inst.step.dependOn(&build_r.step);

    b.getInstallStep().dependOn(&inst.step);
}
