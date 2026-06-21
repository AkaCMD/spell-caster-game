shader_type canvas_item;
render_mode unshaded, blend_mix;

uniform vec4 ripple_color : source_color = vec4(0.55, 0.95, 1.0, 1.0);
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec2 effect_size = vec2(320.0, 320.0);
uniform float max_radius : hint_range(0.0, 0.5) = 0.48;
uniform float ring_spacing : hint_range(0.01, 0.25) = 0.08;
uniform float ring_thickness : hint_range(0.001, 0.08) = 0.012;
uniform float pixel_size : hint_range(1.0, 16.0) = 4.0;
uniform int ring_count : hint_range(1, 12) = 5;


void fragment() {
	vec2 pixel_uv = vec2(pixel_size) / effect_size;
	vec2 pixelated_uv = (floor(UV / pixel_uv) + vec2(0.5)) * pixel_uv;
	vec2 centered_uv = pixelated_uv - vec2(0.5);
	float distance_from_center = length(centered_uv);
	float front_radius = progress * max_radius;
	float ring_alpha = 0.0;

	for (int index = 0; index < 12; index++) {
		if (index >= ring_count) {
			break;
		}

		float radius = front_radius - float(index) * ring_spacing;
		if (radius <= 0.0) {
			continue;
		}

		float ring_distance = abs(distance_from_center - radius);
		float age = clamp((front_radius - radius) / max_radius, 0.0, 1.0);
		float age_fade = 1.0 - age;
		ring_alpha = max(ring_alpha, (1.0 - step(ring_thickness, ring_distance)) * age_fade);
	}

	float end_fade = 1.0 - smoothstep(0.75, 1.0, progress);
	COLOR = vec4(ripple_color.rgb, ripple_color.a * ring_alpha * end_fade);
}
