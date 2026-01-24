// Globe post-process shader entry point
// Applies atmospheric effects to the rendered scene

import package::bindings_post::{u, sceneColor, sceneDepth, sceneSampler};
import package::sun_atmo::UNIT_TO_KM;
import package::sun_blend::{blendAtmosphereSpace, blendAtmosphereGlobe, ATM_EXPOSURE};

// Fullscreen triangle vertex shader
@vertex
fn vs_main(@builtin(vertex_index) vertexIndex: u32) -> @builtin(position) vec4f {
  var pos = array<vec2f, 3>(
    vec2f(-1.0, -1.0),
    vec2f(3.0, -1.0),
    vec2f(-1.0, 3.0)
  );
  return vec4f(pos[vertexIndex], 0.0, 1.0);
}

// Reconstruct world position from screen coords and linear depth
// Globe shader stores: depth = hit.t / (cameraDistance * 2.0)
// So we reverse: hit.t = depth * cameraDistance * 2.0
// Then: worldPos = eyePosition + rayDir * hit.t
fn reconstructWorldPosition(screenPos: vec2f, linearDepth: f32) -> vec3f {
  let rayDir = computeRayPP(screenPos);
  let cameraDistance = length(u.eyePosition);
  let hitT = linearDepth * cameraDistance * 2.0;
  return u.eyePosition + rayDir * hitT;
}

// Compute ray direction for given screen position
fn computeRayPP(fragCoord: vec2f) -> vec3f {
  let ndc = vec2f(
    (fragCoord.x / u.resolution.x) * 2.0 - 1.0,
    1.0 - (fragCoord.y / u.resolution.y) * 2.0
  );

  let forward = -normalize(u.eyePosition);
  let worldUp = vec3f(0.0, 1.0, 0.0);
  let right = normalize(cross(forward, worldUp));
  let up = cross(right, forward);
  let aspect = u.resolution.x / u.resolution.y;

  return normalize(
    forward +
    right * ndc.x * u.tanFov * aspect +
    up * ndc.y * u.tanFov
  );
}

// Check if depth is at far plane (sky/space)
fn isSkyPixel(depth: f32) -> bool {
  return depth > 0.9999;
}

@fragment
fn fs_main(@builtin(position) fragPos: vec4f) -> @location(0) vec4f {
  let screenPos = fragPos.xy;
  let uv = screenPos / u.resolution;

  let color = textureSample(sceneColor, sceneSampler, uv);

  // Load depth directly (depth textures can't use samplers in WebGPU)
  let texCoord = vec2<i32>(fragPos.xy);
  let depth = textureLoad(sceneDepth, texCoord, 0);

  let camera_km = u.eyePosition * UNIT_TO_KM;

  // Sky/space pixel - apply full sky atmosphere
  if (isSkyPixel(depth)) {
    let rayDir = computeRayPP(screenPos);
    return blendAtmosphereSpace(color, rayDir, camera_km, ATM_EXPOSURE, fragPos);
  }

  // Globe pixel - apply surface atmosphere
  let worldPos = reconstructWorldPosition(screenPos, depth);
  let hitPoint = normalize(worldPos);

  return blendAtmosphereGlobe(color, hitPoint, camera_km, ATM_EXPOSURE);
}
