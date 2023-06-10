shader_type canvas_item;

//uniform vec3 color_replace = vec3(1.0,1.0,0.0);
uniform int OCTAVE = 12;
uniform float zoomScale = 1.0;
uniform vec4 CLOUD1_COL: hint_color = vec4(0.41,0.64,0.78,0.4);

const int ANIMATION_TYPE = 1;

float glowLine(in vec2 p, in vec2 a, in vec2 b, float glow) 
{
	vec2 pa = p-a, ba = b-a;
	float h = clamp(dot(pa, ba) / dot(ba , ba), 0.0, 1.0);
	float lineDelta = length(pa - ba * h);
	return max(1.0 - (lineDelta / glow), 0.0);
}

float glowRing(vec2 p, vec2 origin, float radius, float glow) 
{
	float ringDelta = abs(length(p - origin) - radius);
	return max(1.0 - (ringDelta / glow), 0.0);
}

float glowCircle(vec2 p, vec2 origin, float radius, float glow) 
{
	float circleDelta = min(abs(length(p - origin) - radius), 0);
	return max(1.0 - (circleDelta / glow), 0.0);
}

float Quart(float s, float e, float t)
{
    t = clamp((t - s) / (e - s), 0.0, 1.0);
    return 1.0 - pow(1.0 - t, 4.0);
}

float circuit(vec2 p) 
{
	float result = 0.0;
	//result = max(result, glowLine(p, vec2(-1.0, -0.1), vec2(-0.1, -0.1), 10));
	result = max(result, glowLine(p, vec2(-0.1, -0.1), vec2(0.1, 0.1), 0.01));
	result = max(result, glowLine(p, vec2(0.1, 0.1), vec2(1, 0.1), 0.01));
	result = max(result, glowRing(p, vec2(0.5, 0.5), 0.1, 0.01));
    return result;
} 

void fragment() 
{
	float aspectRatio = TEXTURE_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.x;
	vec3 col = vec3(0.0);

	//setup timer loop
	float time = TIME;
	time = mod(time, 4.0);

	float mask;
	float x = UV.x;
	    
	if (ANIMATION_TYPE == 1)
	{
		//setup animation
		float move = Quart(0.0, 1.0, time) - Quart(2.0, 3.0, time);

		//setup mask
		x += 2.0 * aspectRatio * (1.0 - move);
		mask = smoothstep(-aspectRatio, -0.8, x) - smoothstep(0.8, aspectRatio, x);
	}

	if (ANIMATION_TYPE == 2)
	{
		//setup animation
		float moveIn = Quart(0.0, 1.0, time);
		float fadeOut = Quart(3.0, 2.0, time);

		//setup mask
		x += 2.0 * aspectRatio * (1.0 - moveIn);
		mask = smoothstep(-aspectRatio, -0.8, x) - smoothstep(0.8, aspectRatio, x);
		mask *= fadeOut;
	}

	if (ANIMATION_TYPE == 3)
	{    
		//setup animation
		float moveIn = Quart(0.0, 1.0, time);
		float moveOut = Quart(2.0, 3.0, time);

		//setup mask
		x += 2.0 * aspectRatio * (1.0 - moveIn - moveOut);
		mask = smoothstep(-aspectRatio, -0.8, x) - smoothstep(0.8, aspectRatio, x);
	}

	if (ANIMATION_TYPE == 4)
	{    
		//setup animation
		float scale = Quart(0.0, 1.0, time) - Quart(2.0, 3.0, time);

		//setup mask     
		x /= scale;
		mask = smoothstep(-aspectRatio, -0.8, x) - smoothstep(0.8, aspectRatio, x); 
	}

	//draw circuit
	//float shade = circuit(UV / SCREEN_PIXEL_SIZE);
	float shade = texture(TEXTURE, UV).g;
	// col += vec3(1.0, 0.2, 0.0) * shade;
	//col = mix(col, vec3(1.0, 0.2, 0.0), shade);

	//apply mask
	//col *= mask;
	//col = vec3(mask);

	//output
	COLOR = vec4(vec3(2.0, 0.4, 0.0), shade);
}