const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    var main_demo = b.addExecutable("events", "examples/events.zig");

    main_demo.setTarget(target);
    main_demo.setBuildMode(mode);

    main_demo.linkSystemLibrary("kernel32");
    main_demo.addPackagePath("zwc", "src/main.zig");
    main_demo.install();

    const run_cmd = main_demo.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const demo_step = b.step("demo", "Run demo");
    demo_step.dependOn(&run_cmd.step);
}
