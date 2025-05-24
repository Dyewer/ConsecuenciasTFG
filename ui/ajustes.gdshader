shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float brightness : hint_range(-1.0, 1.0) = 0.0;
uniform float contrast   : hint_range(0.0, 2.0)   = 1.0;
uniform float saturation : hint_range(0.0, 2.0)   = 1.0;
uniform float gamma      : hint_range(0.1, 5.0)   = 1.0;

void fragment() {
    vec4 c = texture(SCREEN_TEXTURE, SCREEN_UV);

    c.rgb += brightness;
    c.rgb = ((c.rgb - 0.5) * contrast) + 0.5;

    float luma = dot(c.rgb, vec3(0.299, 0.587, 0.114));
    c.rgb = mix(vec3(luma), c.rgb, saturation);

    c.rgb = pow(c.rgb, vec3(1.0 / gamma));

    COLOR = c;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
