extends Camera

export(NodePath) var spatial_to_follow
export var follow_distance = 4.0
export var track_up_direction_of_subject = true

var max_offset = 10.0
var move_speed = 1000
var spatial : Spatial
var global_position : Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	set_spatial_to_follow(get_node(spatial_to_follow))
	far = 3000
	near = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var target_position = get_follow_position()
	
	var offset = target_position - global_transform.origin
	var move_len = move.length()
	if (move_len * delta > move_speed * delta):
		move = move.normalized() * move_speed
		
	var new_position = global_transform.origin + (move * delta)
	var up = Vector3(global_transform.basis.y)
	if (track_up_direction_of_subject):
		up = spatial.global_transform.basis.y
	look_at_from_position(new_position, spatial.global_transform.origin, up);

func set_spatial_to_follow(spatial : Spatial):
	self.spatial = spatial
	global_transform.origin = get_follow_position()

func get_follow_position():
	return spatial.global_transform.origin +  (spatial.global_transform.basis.z * follow_distance)
