shader_type canvas_item;

void fragment(){
	COLOR = texture(TEXTURE, UV);
	vec3 grey = vec3(0.22 * COLOR.r + 0.71 * COLOR.g + 0.07 * COLOR.b);
	COLOR = vec4(grey,COLOR.a);
}

/*
GLSL code below

uniform sampler2D Texture1;

void main(void) {
    vec4 sample =  texture2D(Texture1, gl_TexCoord[0]);
    vec3 grey = vec3(0.22 * sample.r + 0.71 * sample.g + 0.07 * sample.b);
    gl_FragColor = vec4(grey, sample.a);
}*/

/* Written by ArcticFqx, adapted from NotITG */