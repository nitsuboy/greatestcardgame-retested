shader_type canvas_item;
uniform float interval = 0.5; // the displacement will happen every [interval] seconds
uniform float timeDelay = 0.0; // use it if you don't want all the sprites to move at the same time
uniform float intensityX = 20.0; // X axis force of movement
uniform float intensityY = 20.0; // Y axis force of movement
uniform float seed = 42.0; // seed to randomize movement

void vertex() {
	float chunk = floor((TIME + timeDelay) / interval);
	float seedNum = VERTEX.x + VERTEX.y + chunk + seed;
	float offsetX = sin(seedNum * 12.9898) * 43758.5453;
	float offsetY = sin(seedNum * 32.9472) * 94726.0482;
	offsetX = fract(offsetX);
	offsetX = offsetX * 2.0 - 1.0;
	offsetY = fract(offsetY);
	offsetY = offsetY * 2.0 - 1.0;
	VERTEX += vec2(offsetX * intensityX, offsetY * intensityY);
}