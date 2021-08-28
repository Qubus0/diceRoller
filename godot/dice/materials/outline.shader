shader_type spatial;

render_mode unshaded, cull_front;

uniform float border_width : hint_range(0,1,0.001);
uniform vec4 border_color : hint_color = vec4(1.0);

void vertex() {
    VERTEX += VERTEX * border_width;
}

void fragment() {
    ALBEDO = border_color.xyz;
}