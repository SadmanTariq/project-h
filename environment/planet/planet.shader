shader_type spatial;
render_mode specular_schlick_ggx;
//render_mode unshaded;
//render_mode cull_front;

uniform float seed = 80.;
uniform vec4 oceanColor : hint_color;
uniform vec4 grassColor : hint_color;
uniform vec4 sandColor : hint_color;
uniform vec4 topColor : hint_color;

varying vec3 vertex_pos;
varying vec3 normal_vec;
varying float height;

//	Classic Perlin 3D Noise 
//	by Stefan Gustavson
//
vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
vec4 taylorInvSqrt(vec4 r){return 1.79284291400159 - 0.85373472095314 * r;}
vec3 fade(vec3 t) {return t*t*t*(t*(t*6.0-15.0)+10.0);}

float cnoise(vec3 P){
  vec3 Pi0 = floor(P); // Integer part for indexing
  vec3 Pi1 = Pi0 + vec3(1.0); // Integer part + 1
  Pi0 = mod(Pi0, 289.0);
  Pi1 = mod(Pi1, 289.0);
  vec3 Pf0 = fract(P); // Fractional part for interpolation
  vec3 Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0
  vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
  vec4 iy = vec4(Pi0.yy, Pi1.yy);
  vec4 iz0 = Pi0.zzzz;
  vec4 iz1 = Pi1.zzzz;

  vec4 ixy = permute(permute(ix) + iy);
  vec4 ixy0 = permute(ixy + iz0);
  vec4 ixy1 = permute(ixy + iz1);

  vec4 gx0 = ixy0 / 7.0;
  vec4 gy0 = fract(floor(gx0) / 7.0) - 0.5;
  gx0 = fract(gx0);
  vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
  vec4 sz0 = step(gz0, vec4(0.0));
  gx0 -= sz0 * (step(0.0, gx0) - 0.5);
  gy0 -= sz0 * (step(0.0, gy0) - 0.5);

  vec4 gx1 = ixy1 / 7.0;
  vec4 gy1 = fract(floor(gx1) / 7.0) - 0.5;
  gx1 = fract(gx1);
  vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
  vec4 sz1 = step(gz1, vec4(0.0));
  gx1 -= sz1 * (step(0.0, gx1) - 0.5);
  gy1 -= sz1 * (step(0.0, gy1) - 0.5);

  vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
  vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
  vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
  vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
  vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
  vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
  vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
  vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);

  vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
  g000 *= norm0.x;
  g010 *= norm0.y;
  g100 *= norm0.z;
  g110 *= norm0.w;
  vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
  g001 *= norm1.x;
  g011 *= norm1.y;
  g101 *= norm1.z;
  g111 *= norm1.w;

  float n000 = dot(g000, Pf0);
  float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
  float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
  float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
  float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
  float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
  float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
  float n111 = dot(g111, Pf1);

  vec3 fade_xyz = fade(Pf0);
  vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
  vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
  float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x); 
  return 2.2 * n_xyz;
}
//
//float smin(float a, float b, float k) {
//  float h = clamp(0.5 + 0.5*(a-b)/k, 0.0, 1.0);
//  return mix(a, b, h) - k*h*(1.0-h);
//}

float scaledNoise(in vec3 pos, in float scale, in vec3 offset){
	return cnoise(pos * scale + offset);// / 2.0 + 0.5;
}

float oceanNoise(in vec3 pos){
	float threshold = -0.2;
	float scale = 1.4;
	return smoothstep(threshold, threshold + 0.7,
					  scaledNoise(pos, scale, vec3(seed)));
}

float landNoise(in vec3 pos){
//	float seed = 50.;
	float noise = 0.0;
	int detailIterations = 5;
	float scaleMult = 3.0;
	float ampMult = 0.2;
	vec3 offsetChange = vec3(50.);
	for (int i = 0; i < detailIterations; i++){
		float scale = 1.2 * pow(scaleMult, float(i));
		vec3 offset = vec3(seed) + offsetChange * float(i);
		float amplitude = 1.1 * pow(ampMult, float(i));
		noise += scaledNoise(pos, scale, offset) * amplitude;
	}
	return noise;
}

float mainNoise(in vec3 pos){
//	return landNoise(pos);
//	return landNoise(pos) * oceanNoise(pos);
//	return smin(landNoise(pos), oceanNoise(pos) - 0.3, 1.);
//	return mix(-0.7, landNoise(pos), oceanNoise(pos));
	return max(landNoise(pos) - (1. - oceanNoise(pos)), -0.7);
}

vec3 normal(in vec3 pos, in vec3 normal){
	float offset = .025;
	vec3 binormal = cross(normal, pos);
	vec3 x1 = normalize(pos - normal * offset) * dot(pos, pos);
	vec3 x2 = normalize(pos + normal * offset) * dot(pos, pos);
	vec3 y1 = normalize(pos - binormal * offset) * dot(pos, pos);
	vec3 y2 = normalize(pos + binormal * offset) * dot(pos, pos);
	
	vec3 vx1 = x1 + normalize(x1) * mainNoise(x1);
	vec3 vx2 = x2 + normalize(x2) * mainNoise(x2);
	vec3 vy1 = y1 + normalize(y1) * mainNoise(y1);
	vec3 vy2 = y2 + normalize(y2) * mainNoise(y2);
	
	vec3 x = vx2 - vx1;
	vec3 y = vy2 - vy1;
	return cross(y, x);
}

void fragment(){
	float nHeight = (height + 0.7) / 1.8;
	float water = smoothstep(0.0, 0.02, nHeight);
	ROUGHNESS = clamp(water + 0.2, 0.0, 1.0);
	SPECULAR = (1.0 - water) * 0.4;
	ANISOTROPY_FLOW = vec2(1., 0.);
	ANISOTROPY = (1.0 - water) * 0.8;
	TRANSMISSION = vec3((1.0 - water) * 0.02);

	vec4 landColor = mix(sandColor, mix(grassColor, topColor,
						 smoothstep(0.6, 0.7, nHeight)),
						 smoothstep(0.0, 0.2, nHeight));
	vec3 color = mix(oceanColor, landColor, water).rgb;
	ALBEDO = color;
}

void vertex(){
	vertex_pos = VERTEX;
	normal_vec = NORMAL;
	height = mainNoise(vertex_pos);
	normal_vec = normal(VERTEX, NORMAL);
	VERTEX += NORMAL * height * 0.2;
	NORMAL = normal_vec;
}