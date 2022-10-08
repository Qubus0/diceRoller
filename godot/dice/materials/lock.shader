shader_type spatial;
render_mode unshaded;

const float PI = 3.1415926535;

uniform float spacing = 1.0;
uniform vec4 color : hint_color = vec4( 0.0, 1.0, 0.3, 1.0 );
uniform float line_width : hint_range( 0.0, 1.0 ) = 0.1;
uniform float line_size = 0.05;

varying vec3 local_vertex;

float get_line_ratio( float p )
{
	return step(.1, 
		max(
			-sin( mod( p, line_size ) / line_size * PI ) + line_width, 0.0
		) / line_width
	);
}

void vertex( )
{
	local_vertex = VERTEX;
}

void fragment( )
{
	float v = get_line_ratio( (local_vertex.x + local_vertex.y) / spacing);

	ALBEDO = color.rgb;
	ALPHA = color.a * v;
}
