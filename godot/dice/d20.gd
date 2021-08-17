extends Die

# surface normals
var sides = {
	1: Vector3(0.187597, -0.794651, -0.577354),
	2: Vector3(-0.607065, 0.794652, 0),
	3: Vector3(0.187597, -0.794651, 0.577354),
	4: Vector3(0.491122, 0.794652, -0.356829),
	5: Vector3(-0.303536, 0.187589, -0.934172),
	6: Vector3(0.794649, 0.187587, 0.577359),
	7: Vector3(-0.491122, -0.794652, -0.356829),
	8: Vector3(-0.303536, 0.187589, 0.934172),
	9: Vector3(0.982246, -0.187597, 0),
	10: Vector3(-0.794649, -0.187587, 0.577359),
	11: Vector3(0.794649, 0.187587, -0.577359),
	12: Vector3(-0.982246, 0.187597, 0),
	13: Vector3(0.303536, -0.187589, -0.934172),
	14: Vector3(0.491122, 0.794652, 0.356829),
	15: Vector3(-0.794649, -0.187587, -0.577359),
	16: Vector3(0.303536, -0.187589, 0.934172),
	17: Vector3(-0.491122, -0.794652, 0.356829),
	18: Vector3(-0.187597, 0.794651, -0.577354),
	19: Vector3(0.607065, -0.794652, 0),
	20: Vector3(-0.187597, 0.794651, 0.577354),
}


var sideMarker = preload('res://dice/sideMarker.tscn')

func _ready() -> void:
#	getting surface normals - after running replace 0 with correct side int
#	print('var sides = {')
#	var mdt = MeshDataTool.new()
#	mdt.create_from_surface($Mesh.mesh, 0)
#	for i in mdt.get_face_count():
#		  print('	' + str(0) + ': Vector3' + str(mdt.get_face_normal(i)) + ',')
#	print('}')
	for i in sides:
		var marker = sideMarker.instance()
		marker.name = str(i)
		$Sides.add_child(marker)
		marker.transform.origin = sides[i]

func get_rolled_side() -> int:
	var highest = 0
	var highest_side = 0
	var heights = []
	for side in $Sides.get_children():
		var height = side.global_transform.origin.y
		heights.append(height)
		if height > highest:
			highest = height
			highest_side = int(side.name)
	heights.sort()
	if heights[-1] - heights[-2] < .15:
		return 0
	return highest_side
