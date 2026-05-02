shader_type canvas_item;

uniform vec4 bottom_color: source_color;
uniform vec4 top_color: source_color;

uniform vec2 ratio;
uniform float wave_amp: hint_range(0.0, 0.5);
uniform int wave_size: hint_range(1.0, 50.0);
uniform float flower_size: hint_range(0.0, 1.0);
uniform float wave_time_mul: hint_range(-2.0, 2.0);

uniform int total_phases: hint_range(1, 600, 1);


float rand(float n){return fract(sin(n) * 43758.5453123);}


float noise(float p){
	float fl = floor(p);
	float fc = fract(p);
	return mix(rand(fl), rand(fl + 1.0), fc);
}


float fmod(float x, float y) {
	return x - floor(x / y) * y;
}


vec4 lerp(vec4 a, vec4 b, float w) {
	return a + w * (b - a);
}


void fragment() {
	vec2 uv = vec2(UV.x*ratio.x,UV.y*ratio.y);
	vec2 center = vec2(.5*ratio.x,.5*ratio.y);
	float dx = uv.x - center.x;
	float dy = uv.y - center.y;
	float dist = distance(uv,center);
	float theta = atan(dy, dx);
	float t = float(total_phases);

	float s = (wave_amp * sin(float(wave_size)*theta - (TIME*wave_time_mul*10.)) + flower_size);
	
	float i = .0;
	
	for (float j = 1.; j <= t; j++)
	{
		if(dist>(s/t)*j) i+=1./t;
	}
	
	COLOR = lerp(top_color, bottom_color, i);
}