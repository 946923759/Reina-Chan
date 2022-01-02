shader_type canvas_item;

void fragment(){
	vec3 color = texture(TEXTURE,UV).rgb;
	COLOR.r = color.r*.4;
	COLOR.g = color.g*.4;
	COLOR.b = color.b*.8;
	COLOR.a = texture(TEXTURE,UV).a;
}