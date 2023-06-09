shader_type canvas_item;
uniform float zoomScale = 1.0;
uniform int modulo = 300;
uniform int underValue = 50;
// "Circuit Diagram2" by ntsutae
// https://twitter.com/ntsutae/status/1268820823952916486
// https://www.openprocessing.org/sketch/912094
void fragment(){
	vec2 SCALED_UV = (UV / SCREEN_PIXEL_SIZE) * zoomScale;
	int x = int(SCALED_UV.x);
	int y = int(SCALED_UV.y);
	int r = (x-y)^(x+y);
	// int r = int(pow(float(x-y), float(x+y)));
	// bool b = int(abs(pow(float(r), 1.0))) % modulo < under_value;
	bool b = (r*r*r) % modulo < underValue;
	COLOR = vec4(vec3(b ? 1.0 : 0.0), 1.0);
}