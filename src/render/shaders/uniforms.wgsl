// Shared Uniforms struct - imported by both passes
// Must match TypeScript layout in globe-uniforms.ts
// Note: The binding declaration is in bindings_main.wgsl and bindings_post.wgsl

struct Uniforms {
  viewProjInverse: mat4x4f,   // 64 bytes
  eyePosition: vec3f,         // 12 + 4 pad = 16 bytes
  eyePad: f32,
  resolution: vec2f,          // 8 bytes
  tanFov: f32,                // 4 bytes
  resPad: f32,                // 4 bytes pad = 16 bytes total
  time: f32,                  // 4 bytes
  sunOpacity: f32,            // 4 bytes
  sunPad: vec2f,              // 8 bytes pad
  sunDirection: vec3f,        // 12 + 4 pad = 16 bytes
  sunDirPad: f32,
  sunCoreRadius: f32,         // 4 bytes
  sunGlowRadius: f32,         // 4 bytes
  sunRadiiPad: vec2f,         // 8 bytes pad = 16 bytes
  sunCoreColor: vec3f,        // 12 + 4 pad = 16 bytes
  sunCoreColorPad: f32,
  sunGlowColor: vec3f,        // 12 + 4 pad = 16 bytes
  sunGlowColorPad: f32,
  gridEnabled: u32,
  gridOpacity: f32,
  earthOpacity: f32,
  tempOpacity: f32,
  rainOpacity: f32,
  tempDataReady: u32,
  rainDataReady: u32,
  tempLerp: f32,
  tempLoadedPoints: u32,
  tempSlot0: u32,
  tempSlot1: u32,
  gridFontSize: f32,
  gridLabelMaxRadius: f32,
  gridLineWidth: f32,
  tempPaletteRange: vec2f,
  cloudsOpacity: f32,
  humidityOpacity: f32,
  windOpacity: f32,
  cloudsDataReady: u32,
  humidityDataReady: u32,
  windDataReady: u32,
  logoOpacity: f32,
  logoPad: f32,
}

