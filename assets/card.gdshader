shader_type canvas_item;

uniform float speed = 1.0;
uniform float frequency = 1.0;
uniform bool active = true;

// Function to convert HSV to RGB for smooth rainbow colors
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
    // Scroll based on time and UV position
	if(active){
	float hue = fract(UV.x * frequency + TIME * speed);
    vec3 rainbow = hsv2rgb(vec3(hue, 1.0, 1.0));
    
    // Mix with texture or set color directly
    vec4 texture_color = texture(TEXTURE, UV);
    COLOR = vec4(rainbow, texture_color.a); // Maintains texture transparency
		
	}

}

