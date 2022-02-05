const std = @import("std");
const math = std.math;
const assert = std.debug.assert;
const win32 = @import("win32");
const w = win32.base;
const d2d1 = win32.d2d1;
const d3d12 = win32.d3d12;
const dwrite = win32.dwrite;
const xaudio2 = win32.xaudio2;
const xaudio2fx = win32.xaudio2fx;
const xapo = win32.xapo;
const common = @import("common");
const gfx = common.graphics;
const sfx = common.audio;
const lib = common.library;
const zm = common.zmath;
const c = common.c;

const Mutex = std.Thread.Mutex;
const hrPanic = lib.hrPanic;
const hrPanicOnFail = lib.hrPanicOnFail;
const L = std.unicode.utf8ToUtf16LeStringLiteral;

pub export var D3D12SDKVersion: u32 = 4;
pub export var D3D12SDKPath: [*:0]const u8 = ".\\d3d12\\";

const window_name = "zig-gamedev: audio experiments";
const window_width = 1920;
const window_height = 1080;

const Pso_DrawConst = struct {
    object_to_world: [16]f32,
};

const Pso_FrameConst = struct {
    world_to_clip: [16]f32,
};

const Pso_Vertex = struct {
    position: [3]f32,
    color: [3]f32,
};

const AudioData = struct {
    mutex: Mutex = .{},
    cursor_position: u32 = 99,
    left: std.ArrayList(f32),
    right: std.ArrayList(f32),

    fn init(allocator: std.mem.Allocator) AudioData {
        const size = 100 * 480;

        var left = std.ArrayList(f32).initCapacity(allocator, size) catch unreachable;
        left.resize(size) catch unreachable;
        for (left.items) |*s| s.* = 0.0;

        var right = std.ArrayList(f32).initCapacity(allocator, size) catch unreachable;
        right.resize(size) catch unreachable;
        for (right.items) |*s| s.* = 0.0;

        return .{
            .left = left,
            .right = right,
        };
    }

    fn deinit(audio_data: *AudioData) void {
        audio_data.left.deinit();
        audio_data.right.deinit();
        audio_data.* = undefined;
    }
};

const DemoState = struct {
    gctx: gfx.GraphicsContext,
    actx: sfx.AudioContext,
    guictx: gfx.GuiContext,
    frame_stats: lib.FrameStats,

    music: *sfx.Stream,
    music_is_playing: bool = true,
    music_has_reverb: bool = false,
    sound1_data: []const u8,
    sound2_data: []const u8,
    sound3_data: []const u8,

    brush: *d2d1.ISolidColorBrush,
    normal_tfmt: *dwrite.ITextFormat,

    lines_pso: gfx.PipelineHandle,

    depth_texture: gfx.ResourceHandle,
    depth_texture_dsv: d3d12.CPU_DESCRIPTOR_HANDLE,

    audio_data: *AudioData,

    camera: struct {
        position: [3]f32 = .{ -10.0, 15.0, -10.0 },
        forward: [3]f32 = .{ 0.0, 0.0, 1.0 },
        pitch: f32 = 0.15 * math.pi,
        yaw: f32 = 0.25 * math.pi,
    } = .{},
    mouse: struct {
        cursor_prev_x: i32 = 0,
        cursor_prev_y: i32 = 0,
    } = .{},
};

fn processAudio(samples: []f32, num_channels: u32, context: ?*anyopaque) void {
    const audio_data = @ptrCast(*AudioData, @alignCast(@sizeOf(usize), context));

    audio_data.mutex.lock();
    defer audio_data.mutex.unlock();

    audio_data.cursor_position = (audio_data.cursor_position + 1) % 100;

    const base_index = 480 * audio_data.cursor_position;
    var i: u32 = 0;
    if (num_channels == 0) { // silence, 'samples' may contain invalid data
        while (i < 480) : (i += 1) {
            audio_data.left.items[base_index + i] = 0.0;
            audio_data.right.items[base_index + i] = 0.0;
        }
    } else {
        while (i < 480) : (i += 1) {
            audio_data.left.items[base_index + i] = samples[i * num_channels];
            audio_data.right.items[base_index + i] = samples[i * num_channels + 1];
        }
    }
}

fn init(gpa_allocator: std.mem.Allocator) DemoState {
    {
        //var t = [_]zm.F32x4{zm.f32x4s(0.0)} ** 32;
        //zm.fftInitUnityTable(t[0..]);
        //std.log.info("{any}", .{t});
    }

    var actx = sfx.AudioContext.init(gpa_allocator);

    const sound1_data = sfx.loadBufferData(gpa_allocator, L("content/drum_bass_hard.flac"));
    const sound2_data = sfx.loadBufferData(gpa_allocator, L("content/tabla_tas1.flac"));
    const sound3_data = sfx.loadBufferData(gpa_allocator, L("content/loop_mika.flac"));

    var music = sfx.Stream.create(gpa_allocator, actx.device, L("content/Broke For Free - Night Owl.mp3"));
    hrPanicOnFail(music.voice.Start(0, xaudio2.COMMIT_NOW));

    {
        var reverb_apo: ?*w.IUnknown = null;
        hrPanicOnFail(xaudio2fx.createReverb(&reverb_apo, 0));
        defer _ = reverb_apo.?.Release();

        var effect_descriptor = [_]xaudio2.EFFECT_DESCRIPTOR{.{
            .pEffect = reverb_apo.?,
            .InitialState = w.FALSE,
            .OutputChannels = 2,
        }};
        const effect_chain = xaudio2.EFFECT_CHAIN{ .EffectCount = 1, .pEffectDescriptors = &effect_descriptor };
        hrPanicOnFail(music.voice.SetEffectChain(&effect_chain));

        hrPanicOnFail(music.voice.SetEffectParameters(
            0,
            &xaudio2fx.REVERB_PARAMETERS.initDefault(),
            @sizeOf(xaudio2fx.REVERB_PARAMETERS),
            xaudio2.COMMIT_NOW,
        ));
    }

    const audio_data = gpa_allocator.create(AudioData) catch unreachable;
    audio_data.* = AudioData.init(gpa_allocator);

    {
        const p0 = sfx.createSimpleProcessor(&processAudio, audio_data);
        defer _ = p0.Release();

        var effect_descriptor = [_]xaudio2.EFFECT_DESCRIPTOR{
            .{
                .pEffect = p0,
                .InitialState = w.TRUE,
                .OutputChannels = 2,
            },
        };
        const effect_chain = xaudio2.EFFECT_CHAIN{
            .EffectCount = effect_descriptor.len,
            .pEffectDescriptors = &effect_descriptor,
        };

        hrPanicOnFail(actx.master_voice.SetEffectChain(&effect_chain));
    }

    const window = lib.initWindow(gpa_allocator, window_name, window_width, window_height) catch unreachable;

    var arena_allocator_state = std.heap.ArenaAllocator.init(gpa_allocator);
    defer arena_allocator_state.deinit();
    const arena_allocator = arena_allocator_state.allocator();

    var gctx = gfx.GraphicsContext.init(window);
    gctx.present_flags = 0;
    gctx.present_interval = 1;

    const brush = blk: {
        var brush: ?*d2d1.ISolidColorBrush = null;
        hrPanicOnFail(gctx.d2d.context.CreateSolidColorBrush(
            &.{ .r = 1.0, .g = 0.0, .b = 0.0, .a = 0.5 },
            null,
            &brush,
        ));
        break :blk brush.?;
    };

    const normal_tfmt = blk: {
        var info_txtfmt: ?*dwrite.ITextFormat = null;
        hrPanicOnFail(gctx.dwrite_factory.CreateTextFormat(
            L("Verdana"),
            null,
            .BOLD,
            .NORMAL,
            .NORMAL,
            32.0,
            L("en-us"),
            &info_txtfmt,
        ));
        break :blk info_txtfmt.?;
    };
    hrPanicOnFail(normal_tfmt.SetTextAlignment(.LEADING));
    hrPanicOnFail(normal_tfmt.SetParagraphAlignment(.NEAR));

    const lines_pso = blk: {
        const input_layout_desc = [_]d3d12.INPUT_ELEMENT_DESC{
            d3d12.INPUT_ELEMENT_DESC.init("POSITION", 0, .R32G32B32_FLOAT, 0, 0, .PER_VERTEX_DATA, 0),
            d3d12.INPUT_ELEMENT_DESC.init("_Color", 0, .R32G32B32_FLOAT, 0, 12, .PER_VERTEX_DATA, 0),
        };

        var pso_desc = d3d12.GRAPHICS_PIPELINE_STATE_DESC.initDefault();
        pso_desc.InputLayout = .{
            .pInputElementDescs = &input_layout_desc,
            .NumElements = input_layout_desc.len,
        };
        pso_desc.RTVFormats[0] = .R8G8B8A8_UNORM;
        pso_desc.NumRenderTargets = 1;
        pso_desc.DSVFormat = .D32_FLOAT;
        pso_desc.BlendState.RenderTarget[0].RenderTargetWriteMask = 0xf;
        pso_desc.PrimitiveTopologyType = .LINE;

        break :blk gctx.createGraphicsShaderPipeline(
            arena_allocator,
            &pso_desc,
            "content/shaders/lines.vs.cso",
            "content/shaders/lines.ps.cso",
        );
    };

    // Create depth texture resource.
    const depth_texture = gctx.createCommittedResource(
        .DEFAULT,
        d3d12.HEAP_FLAG_NONE,
        &blk: {
            var desc = d3d12.RESOURCE_DESC.initTex2d(.D32_FLOAT, gctx.viewport_width, gctx.viewport_height, 1);
            desc.Flags = d3d12.RESOURCE_FLAG_ALLOW_DEPTH_STENCIL | d3d12.RESOURCE_FLAG_DENY_SHADER_RESOURCE;
            break :blk desc;
        },
        d3d12.RESOURCE_STATE_DEPTH_WRITE,
        &d3d12.CLEAR_VALUE.initDepthStencil(.D32_FLOAT, 1.0, 0),
    ) catch |err| hrPanic(err);

    // Create depth texture view.
    const depth_texture_dsv = gctx.allocateCpuDescriptors(.DSV, 1);
    gctx.device.CreateDepthStencilView(
        gctx.getResource(depth_texture),
        null,
        depth_texture_dsv,
    );

    //
    // Begin frame to init/upload resources to the GPU.
    //
    gctx.beginFrame();

    var guictx = gfx.GuiContext.init(arena_allocator, &gctx, 1);

    gctx.endFrame();
    gctx.finishGpuCommands();

    return .{
        .gctx = gctx,
        .actx = actx,
        .guictx = guictx,
        .music = music,
        .sound1_data = sound1_data,
        .sound2_data = sound2_data,
        .sound3_data = sound3_data,
        .frame_stats = lib.FrameStats.init(),
        .brush = brush,
        .normal_tfmt = normal_tfmt,
        .audio_data = audio_data,
        .lines_pso = lines_pso,
        .depth_texture = depth_texture,
        .depth_texture_dsv = depth_texture_dsv,
    };
}

fn deinit(demo: *DemoState, gpa_allocator: std.mem.Allocator) void {
    demo.gctx.finishGpuCommands();
    demo.actx.device.StopEngine();
    _ = demo.gctx.releasePipeline(demo.lines_pso);
    _ = demo.gctx.releaseResource(demo.depth_texture);
    _ = demo.brush.Release();
    _ = demo.normal_tfmt.Release();
    demo.guictx.deinit(&demo.gctx);
    demo.gctx.deinit();
    demo.music.destroy();
    gpa_allocator.free(demo.sound1_data);
    gpa_allocator.free(demo.sound2_data);
    gpa_allocator.free(demo.sound3_data);
    demo.audio_data.deinit();
    gpa_allocator.destroy(demo.audio_data);
    demo.actx.deinit();
    lib.deinitWindow(gpa_allocator);
    demo.* = undefined;
}

fn update(demo: *DemoState) void {
    demo.frame_stats.update();
    const dt = demo.frame_stats.delta_time;
    lib.newImGuiFrame(dt);

    c.igSetNextWindowPos(
        c.ImVec2{ .x = @intToFloat(f32, demo.gctx.viewport_width) - 600.0 - 20, .y = 20.0 },
        c.ImGuiCond_FirstUseEver,
        c.ImVec2{ .x = 0.0, .y = 0.0 },
    );
    c.igSetNextWindowSize(.{ .x = 600.0, .y = -1 }, c.ImGuiCond_Always);

    _ = c.igBegin(
        "Demo Settings",
        null,
        c.ImGuiWindowFlags_NoMove | c.ImGuiWindowFlags_NoResize | c.ImGuiWindowFlags_NoSavedSettings,
    );
    c.igBulletText("", "");
    c.igSameLine(0, -1);
    c.igTextColored(.{ .x = 0, .y = 0.8, .z = 0, .w = 1 }, "Right Mouse Button + drag", "");
    c.igSameLine(0, -1);
    c.igText(" :  rotate camera", "");

    c.igBulletText("", "");
    c.igSameLine(0, -1);
    c.igTextColored(.{ .x = 0, .y = 0.8, .z = 0, .w = 1 }, "W, A, S, D", "");
    c.igSameLine(0, -1);
    c.igText(" :  move camera", "");

    c.igText("Music:", "");
    if (c.igButton(
        if (demo.music_is_playing) "  Pause  " else "  Play  ",
        .{ .x = 0, .y = 0 },
    )) {
        demo.music_is_playing = !demo.music_is_playing;
        if (demo.music_is_playing) {
            hrPanicOnFail(demo.music.voice.Start(0, xaudio2.COMMIT_NOW));
        } else {
            hrPanicOnFail(demo.music.voice.Stop(0, xaudio2.COMMIT_NOW));
        }
    }
    c.igSameLine(0.0, -1.0);
    if (c.igButton("  Rewind  ", .{ .x = 0, .y = 0 })) {
        demo.music.setCurrentPosition(0);
    }
    c.igSameLine(0.0, -1.0);
    if (c.igButton(
        if (demo.music_has_reverb) "  No Reverb  " else "  Reverb  ",
        .{ .x = 0, .y = 0 },
    )) {
        demo.music_has_reverb = !demo.music_has_reverb;
        if (demo.music_has_reverb) {
            hrPanicOnFail(demo.music.voice.EnableEffect(0, xaudio2.COMMIT_NOW));
        } else {
            hrPanicOnFail(demo.music.voice.DisableEffect(0, xaudio2.COMMIT_NOW));
        }
    }
    c.igSpacing();

    c.igText("Sounds:", "");
    if (c.igButton("  Play Sound 1  ", .{ .x = 0, .y = 0 })) {
        demo.actx.playBuffer(.{ .data = demo.sound1_data });
    }
    c.igSameLine(0.0, -1.0);
    if (c.igButton("  Play Sound 2  ", .{ .x = 0, .y = 0 })) {
        demo.actx.playBuffer(.{ .data = demo.sound2_data });
    }
    c.igSameLine(0.0, -1.0);
    if (c.igButton("  Play Sound 3  ", .{ .x = 0, .y = 0 })) {
        demo.actx.playBuffer(.{ .data = demo.sound3_data });
    }

    c.igEnd();

    // Handle camera rotation with mouse.
    {
        var pos: w.POINT = undefined;
        _ = w.GetCursorPos(&pos);
        const delta_x = @intToFloat(f32, pos.x) - @intToFloat(f32, demo.mouse.cursor_prev_x);
        const delta_y = @intToFloat(f32, pos.y) - @intToFloat(f32, demo.mouse.cursor_prev_y);
        demo.mouse.cursor_prev_x = pos.x;
        demo.mouse.cursor_prev_y = pos.y;

        if (w.GetAsyncKeyState(w.VK_RBUTTON) < 0) {
            demo.camera.pitch += 0.0025 * delta_y;
            demo.camera.yaw += 0.0025 * delta_x;
            demo.camera.pitch = math.min(demo.camera.pitch, 0.48 * math.pi);
            demo.camera.pitch = math.max(demo.camera.pitch, -0.48 * math.pi);
            demo.camera.yaw = zm.modAngle(demo.camera.yaw);
        }
    }

    // Handle camera movement with 'WASD' keys.
    {
        const speed = zm.f32x4s(10.0);
        const delta_time = zm.f32x4s(demo.frame_stats.delta_time);
        const transform = zm.mul(zm.rotationX(demo.camera.pitch), zm.rotationY(demo.camera.yaw));
        var forward = zm.normalize3(zm.mul(zm.f32x4(0.0, 0.0, 1.0, 0.0), transform));

        zm.store(demo.camera.forward[0..], forward, 3);

        const right = speed * delta_time * zm.normalize3(zm.cross3(zm.f32x4(0.0, 1.0, 0.0, 0.0), forward));
        forward = speed * delta_time * forward;

        // Load camera position from memory to SIMD register ('3' means that we want to load three components).
        var cpos = zm.load(demo.camera.position[0..], zm.Vec, 3);

        if (w.GetAsyncKeyState('W') < 0) {
            cpos += forward;
        } else if (w.GetAsyncKeyState('S') < 0) {
            cpos -= forward;
        }
        if (w.GetAsyncKeyState('D') < 0) {
            cpos += right;
        } else if (w.GetAsyncKeyState('A') < 0) {
            cpos -= right;
        }

        // Copy updated position from SIMD register to memory.
        zm.store(demo.camera.position[0..], cpos, 3);
    }
}

fn draw(demo: *DemoState) void {
    var gctx = &demo.gctx;

    const cam_world_to_view = zm.lookToLh(
        zm.load(demo.camera.position[0..], zm.Vec, 3),
        zm.load(demo.camera.forward[0..], zm.Vec, 3),
        zm.f32x4(0.0, 1.0, 0.0, 0.0),
    );
    const cam_view_to_clip = zm.perspectiveFovLh(
        0.25 * math.pi,
        @intToFloat(f32, gctx.viewport_width) / @intToFloat(f32, gctx.viewport_height),
        0.01,
        200.0,
    );
    const cam_world_to_clip = zm.mul(cam_world_to_view, cam_view_to_clip);

    gctx.beginFrame();

    const back_buffer = gctx.getBackBuffer();
    gctx.addTransitionBarrier(back_buffer.resource_handle, d3d12.RESOURCE_STATE_RENDER_TARGET);
    gctx.flushResourceBarriers();

    gctx.cmdlist.OMSetRenderTargets(
        1,
        &[_]d3d12.CPU_DESCRIPTOR_HANDLE{back_buffer.descriptor_handle},
        w.TRUE,
        &demo.depth_texture_dsv,
    );
    gctx.cmdlist.ClearRenderTargetView(
        back_buffer.descriptor_handle,
        &[4]f32{ 0.0, 0.0, 0.0, 1.0 },
        0,
        null,
    );
    gctx.cmdlist.ClearDepthStencilView(demo.depth_texture_dsv, d3d12.CLEAR_FLAG_DEPTH, 1.0, 0, 0, null);

    gctx.setCurrentPipeline(demo.lines_pso);
    gctx.cmdlist.IASetPrimitiveTopology(.LINESTRIP);

    // Upload per-frame constant data (camera xform).
    {
        const mem = gctx.allocateUploadMemory(Pso_FrameConst, 1);
        zm.storeF32x4x4(mem.cpu_slice[0].world_to_clip[0..], zm.transpose(cam_world_to_clip));
        gctx.cmdlist.SetGraphicsRootConstantBufferView(1, mem.gpu_base);
    }

    // Upload per-draw constant data (object to world xform).
    {
        const object_to_world = zm.translation(0.0, 0.0, 0.0);
        const mem = gctx.allocateUploadMemory(Pso_DrawConst, 1);
        zm.storeF32x4x4(mem.cpu_slice[0].object_to_world[0..], zm.transpose(object_to_world));
        gctx.cmdlist.SetGraphicsRootConstantBufferView(0, mem.gpu_base);
    }

    // Upload vertex data and record draw commands.
    {
        demo.audio_data.mutex.lock();
        defer demo.audio_data.mutex.unlock();

        var row: u32 = 0;
        while (row < 100) : (row += 1) {
            const num_vertices: u32 = 480;
            const mem = gctx.allocateUploadMemory(Pso_Vertex, num_vertices);

            const z = (demo.audio_data.cursor_position + row) % 100;
            const f = if (row == 0) 1.0 else 0.010101 * @intToFloat(f32, row - 1);

            var x: u32 = 0;
            while (x < num_vertices) : (x += 1) {
                const sample = demo.audio_data.left.items[x + z * num_vertices];

                var color: [3]f32 = undefined;
                zm.store(color[0..], zm.lerp(
                    zm.f32x4(0.2, 1.0, 0.0, 0.0),
                    zm.f32x4(1.0, 0.0, 0.0, 0.0),
                    1.2 * math.sqrt(f) * math.fabs(sample),
                ), 3);

                mem.cpu_slice[x] = Pso_Vertex{
                    .position = [_]f32{
                        0.1 * @intToFloat(f32, x),
                        f * f * f * 10.0 * sample,
                        0.5 * @intToFloat(f32, z),
                    },
                    .color = color,
                };
            }

            gctx.cmdlist.IASetVertexBuffers(0, 1, &[_]d3d12.VERTEX_BUFFER_VIEW{.{
                .BufferLocation = mem.gpu_base,
                .SizeInBytes = num_vertices * @sizeOf(Pso_Vertex),
                .StrideInBytes = @sizeOf(Pso_Vertex),
            }});
            gctx.cmdlist.DrawInstanced(num_vertices, 1, 0, 0);
        }
    }

    demo.guictx.draw(gctx);

    gctx.beginDraw2d();
    {
        const stats = &demo.frame_stats;
        var buffer = [_]u8{0} ** 64;
        const text = std.fmt.bufPrint(
            buffer[0..],
            "FPS: {d:.1}\nCPU time: {d:.3} ms",
            .{ stats.fps, stats.average_cpu_time },
        ) catch unreachable;

        demo.brush.SetColor(&.{ .r = 1.0, .g = 1.0, .b = 1.0, .a = 1.0 });
        lib.drawText(
            gctx.d2d.context,
            text,
            demo.normal_tfmt,
            &d2d1.RECT_F{
                .left = 10.0,
                .top = 10.0,
                .right = @intToFloat(f32, gctx.viewport_width),
                .bottom = @intToFloat(f32, gctx.viewport_height),
            },
            @ptrCast(*d2d1.IBrush, demo.brush),
        );
    }
    gctx.endDraw2d();

    gctx.endFrame();
}

pub fn main() !void {
    lib.init();
    defer lib.deinit();

    var gpa_allocator_state = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leaked = gpa_allocator_state.deinit();
        std.debug.assert(leaked == false);
    }
    const gpa_allocator = gpa_allocator_state.allocator();

    var demo = init(gpa_allocator);
    defer deinit(&demo, gpa_allocator);

    while (true) {
        var message = std.mem.zeroes(w.user32.MSG);
        const has_message = w.user32.peekMessageA(&message, null, 0, 0, w.user32.PM_REMOVE) catch false;
        if (has_message) {
            _ = w.user32.translateMessage(&message);
            _ = w.user32.dispatchMessageA(&message);
            if (message.message == w.user32.WM_QUIT) {
                break;
            }
        } else {
            update(&demo);
            draw(&demo);
        }
    }
}
