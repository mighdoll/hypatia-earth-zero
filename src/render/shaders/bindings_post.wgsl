// Post-process pass bindings (globe_post.wesl) - bindings 0-7
// Centralized binding declarations for the post-process pass

import package::uniforms::Uniforms;

// Binding 0: Uniforms (same struct as main pass)
@group(0) @binding(0) var<uniform> u: Uniforms;

// Bindings 1-3: Scene textures from main pass
@group(0) @binding(1) var sceneColor: texture_2d<f32>;
@group(0) @binding(2) var sceneDepth: texture_depth_2d;
@group(0) @binding(3) var sceneSampler: sampler;

// Bindings 4-7: Atmosphere LUTs for Bruneton scattering
@group(0) @binding(4) var atm_transmittance: texture_2d<f32>;
@group(0) @binding(5) var atm_scattering: texture_3d<f32>;
@group(0) @binding(6) var atm_irradiance: texture_2d<f32>;
@group(0) @binding(7) var atm_sampler: sampler;
