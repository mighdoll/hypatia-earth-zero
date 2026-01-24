// Main pass bindings (globe_main.wesl) - bindings 0-21
// Centralized binding declarations for the main render pass

import package::uniforms::Uniforms;

// Binding 0: Uniforms
@group(0) @binding(0) var<uniform> u: Uniforms;

// Bindings 1-2: Basemap cubemap
@group(0) @binding(1) var basemap: texture_cube<f32>;
@group(0) @binding(2) var basemapSampler: sampler;

// Bindings 3-6: Temperature data (Gaussian grid)
@group(0) @binding(3) var<storage, read> gaussianLats: array<f32>;
@group(0) @binding(4) var<storage, read> ringOffsets: array<u32>;
@group(0) @binding(5) var<storage, read> tempData0: array<f32>;
@group(0) @binding(6) var<storage, read> tempData1: array<f32>;

// Bindings 7-10: Atmosphere LUTs (unused in main pass, but part of bind group layout)
@group(0) @binding(7) var atm_transmittance_main: texture_2d<f32>;
@group(0) @binding(8) var atm_scattering_main: texture_3d<f32>;
@group(0) @binding(9) var atm_irradiance_main: texture_2d<f32>;
@group(0) @binding(10) var atm_sampler_main: sampler;

// Bindings 11-12: Font atlas for grid labels
@group(0) @binding(11) var fontAtlas: texture_2d<f32>;
@group(0) @binding(12) var fontSampler: sampler;

// Bindings 13-14: Temperature palette
@group(0) @binding(13) var tempPalette: texture_2d<f32>;
@group(0) @binding(14) var tempPaletteSampler: sampler;

// Bindings 15-18: Weather data layers
@group(0) @binding(15) var<storage, read> cloudsData: array<f32>;
@group(0) @binding(16) var<storage, read> humidityData: array<f32>;
@group(0) @binding(17) var<storage, read> windData: array<f32>;
@group(0) @binding(18) var<storage, read> rainData: array<f32>;

// Bindings 19-20: Logo texture
@group(0) @binding(19) var logoTexture: texture_2d<f32>;
@group(0) @binding(20) var logoSampler: sampler;

// Binding 21: Grid lines uniform
// Grid line data from GridAnimator
// Uses vec4 packing for 16-byte uniform alignment: 20 vec4s = 80 floats
struct GridLines {
  lonDegrees: array<vec4<f32>, 20>,    // longitude line positions (80 floats)
  lonOpacities: array<vec4<f32>, 20>,  // longitude line opacities (80 floats)
  latDegrees: array<vec4<f32>, 20>,    // latitude line positions (80 floats)
  latOpacities: array<vec4<f32>, 20>,  // latitude line opacities (80 floats)
  lonCount: u32,                        // active longitude lines
  latCount: u32,                        // active latitude lines
  isAnimating: u32,                     // 1 if transitioning between LoD levels
  spacing: f32,                         // current LoD spacing in degrees (same for lon/lat)
  _pad0: f32,                           // padding (was latSpacing, now unused)
  _pad1: f32,
  _pad2: f32,
  _pad3: f32,
}

@group(0) @binding(21) var<uniform> gridLines: GridLines;
