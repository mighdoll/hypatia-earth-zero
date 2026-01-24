// Globe main shader entry point
// WESL imports bring symbols into scope from other modules

import package::bindings_main::u;
import package::common::{raySphereIntersect, raySphereIntersectFar, EARTH_RADIUS, BG_COLOR};
import package::base::blendBasemap;
import package::temp::blendTemp;
import package::rain::blendRain;
import package::grid::blendGrid;
import package::grid_text::blendGridText;
import package::logo::blendLogo;

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

fn computeRay(fragCoord: vec2f) -> vec3f {
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

struct FragmentOutput {
  @location(0) color: vec4f,
  @builtin(frag_depth) depth: f32,
}

@fragment
fn fs_main(@builtin(position) fragPos: vec4f) -> FragmentOutput {
  let rayDir = computeRay(fragPos.xy);
  let hit = raySphereIntersect(u.eyePosition, rayDir, EARTH_RADIUS);

  if (!hit.valid) {
    return FragmentOutput(BG_COLOR, 1.0);
  }

  let lat = asin(hit.point.y);
  let lon = atan2(hit.point.x, hit.point.z);

  var color = vec4f(0.086, 0.086, 0.086, 1.0);
  color = blendBasemap(color, hit.point);
  color = blendTemp(color, lat, lon);
  color = blendRain(color, lat, lon);

  let maxOpacity = max(u.earthOpacity, u.tempOpacity);
  let fadeAmount = smoothstep(0.3, 0.0, maxOpacity);
  if (fadeAmount > 0.01) {
    let farHit = raySphereIntersectFar(u.eyePosition, rayDir, EARTH_RADIUS);
    if (farHit.valid) {
      let backViewAngle = dot(normalize(farHit.point), -rayDir);
      let limbFactor = 1.0 - backViewAngle;
      let backOpacity = smoothstep(1.0 - fadeAmount, 1.0, limbFactor);

      let backLat = asin(farHit.point.y);
      let backLon = atan2(farHit.point.x, farHit.point.z);
      let colorBeforeBack = color;
      color = blendGrid(color, backLat, backLon, farHit.point);
      color = blendGridText(color, backLat, backLon, farHit.point);
      color = mix(colorBeforeBack, color, backOpacity);
    }
  }

  color = blendGrid(color, lat, lon, hit.point);
  color = blendGridText(color, lat, lon, hit.point);
  color = blendLogo(color, fragPos.xy);

  let cameraDistance = length(u.eyePosition);
  var normalizedDepth = clamp(hit.t / (cameraDistance * 2.0), 0.0, 1.0);

  let depthFadeAmount = smoothstep(0.3, 0.0, max(u.earthOpacity, u.tempOpacity));
  if (depthFadeAmount > 0.01) {
    let viewAngle = dot(normalize(hit.point), -rayDir);
    let limbFactor = 1.0 - viewAngle;
    let limbPush = smoothstep(1.0 - depthFadeAmount, 1.0, limbFactor);
    let depthPush = max(limbPush, depthFadeAmount);
    normalizedDepth = mix(normalizedDepth, 0.9999, depthPush);
  }

  return FragmentOutput(color, normalizedDepth);
}
