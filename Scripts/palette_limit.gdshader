shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform vec3 darkest_shade : source_color  = vec3(0.11, 0.10, 0.19);
uniform vec3 dark_shade : source_color  = vec3(0.15, 0.24, 0.43);
uniform vec3 light_shade : source_color  = vec3(0.18, 0.45, 0.62);
uniform vec3 lightest_shade : source_color  = vec3(0.29, 0.76, 0.81);


const vec3 palette[7] = vec3[7](
    vec3(0.11, 0.10, 0.19), // 191930
    vec3(0.15, 0.24, 0.43), // 263d6e
    vec3(0.18, 0.45, 0.62), // 2f729e
    vec3(0.29, 0.76, 0.81), // 4ac1cf
    vec3(1.00, 0.62, 0.27), // ff9f46
    vec3(1.00, 0.84, 0.45), // ffd772
    vec3(1.00, 0.96, 0.85)  // fff5d9
);

void fragment() {
    vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
    vec3 input_color = color.rgb;
    
    float min_distance = distance(input_color, palette[0]);
    vec3 closest_color = palette[0];
    
    for (int i = 1; i < 7; i++) {
        float current_distance = distance(input_color, palette[i]);
        if (current_distance < min_distance) {
            min_distance = current_distance;
            closest_color = palette[i];
        }
    }
    
	if (closest_color == vec3(0.11, 0.10, 0.19)){
		closest_color = darkest_shade;
	}
	else if (closest_color == vec3(0.15, 0.24, 0.43)){
		closest_color = dark_shade;
	}
	else if (closest_color == vec3(0.18, 0.45, 0.62)){
		closest_color = light_shade;
	}
	else if (closest_color == vec3(0.29, 0.76, 0.81)){
		closest_color = lightest_shade;
	}
	
    COLOR = vec4(closest_color, color.a);
}