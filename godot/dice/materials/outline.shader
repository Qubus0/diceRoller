shader_type spatial;

render_mode unshaded, cull_front;

uniform bool enabled = true;
uniform float border_width : hint_range(0, 1, 0);
uniform vec4 border_color : hint_color = vec4(1.0);

void vertex() {
    VERTEX += enabled ? (VERTEX * border_width) : vec3(0, 0, 0);
}

void fragment() {
    ALBEDO = border_color.rgb;
}