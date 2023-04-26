extends Spatial

var pine_tree_scene = preload("res://TreePine.tscn")
var willow_tree_scene = preload("res://TreeWillow.tscn")
var house_2x1_scene = preload("res://House2X1.tscn")
onready var terrain_static_body = $TerrainStaticBody

export var noise_period = 1000
export var local_noise_period = 300
export var local_noise_octaves = 7
export var noise_octaves = 1
export var height_multiplier = 100
export var squares : int = 512
export var square_size = 10
var noise
var local_noise
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	noise = OpenSimplexNoise.new()
	noise.period = noise_period
	noise.octaves = noise_octaves

	local_noise = OpenSimplexNoise.new()
	local_noise.period = local_noise_period
	local_noise.octaves = local_noise_octaves

	var plane_mesh_subdivide = squares - 1
	var plane_mesh_size = squares * square_size
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(plane_mesh_size, plane_mesh_size)

	plane_mesh.subdivide_depth = plane_mesh_subdivide
	plane_mesh.subdivide_width = plane_mesh_subdivide

	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)

	var array_plane = surface_tool.commit()

	var data_tool = MeshDataTool.new()

	data_tool.create_from_surface(array_plane, 0)
				
	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		vertex.y = get_terrain_height(vertex)
		data_tool.set_vertex(i, vertex)

	for i in range(array_plane.get_surface_count()):
		array_plane.surface_remove(i)

	var quad_size = plane_mesh_size / squares

	for z in range(squares):
		for x in range(squares):
			var start_position = Vector3(-plane_mesh_size / 2, 0.0, -plane_mesh_size / 2)
			var location = Vector3(x * quad_size, 0, z * quad_size) + start_position
			var mid = location + Vector3(quad_size / 2, 0, quad_size / 2)
			mid.y = get_terrain_height(mid)

			if (mid.y > 0.0 and local_noise.get_noise_3d(mid.z, 0, mid.y) > 0.1 and randi() % 20 == 0):
				var h = mid.y
				if (h > 1.0 and h < height_multiplier * 0.2):
					var tree = willow_tree_scene.instance()
					tree.transform.origin = mid
					tree.rotation_degrees.y = randf() * 360
					add_child(tree)
				elif (h > 0.2 * height_multiplier):
					var tree = pine_tree_scene.instance()
					tree.transform.origin = mid
					tree.rotation_degrees.y = randf() * 360
					add_child(tree)
			else:
				if abs(local_noise.get_noise_3d(mid.x * 10, mid.y * 10, mid.z * 10) - 0.5) < 0.002 and mid.y > 1.0:
					var house = house_2x1_scene.instance()
					house.transform.origin = mid
					house.rotation_degrees.y = ((randi() % 4) + 1) * 90
					add_child(house)
		
	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()

	var mesh_instance = MeshInstance.new()
	mesh_instance.mesh = surface_tool.commit()
	mesh_instance.set_surface_material(0, load("res://Terrain.tres"))
	terrain_static_body.add_child(mesh_instance.create_trimesh_collision())

	add_child(mesh_instance)

func get_terrain_height(vertex : Vector3):
	var noise_level = clamp(noise.get_noise_3d(vertex.x, vertex.y, vertex.z) + 0.25, -1.0, 1.0)
	var altitude_y = (noise_level * (abs(noise_level))) * height_multiplier
	var local_height_multiplier = height_multiplier * clamp(noise_level, 0.0, 1.0) / 3
	var local_y = abs(local_noise.get_noise_3d(vertex.x, vertex.y, vertex.z)) * local_height_multiplier
	
	var y = altitude_y + local_y
	if y <= 0.0:
		y -= 1
	else:
		y += 1
	return y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
