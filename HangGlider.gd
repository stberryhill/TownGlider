extends RigidBody

var max_wind_thrust = 300
var wind_direction = Vector3.UP
var roll_speed = 10000
var roll = 0
var pitch_speed = 8000
var pitch = 0
var yaw = 0
var start = false
export var lift = Vector3()
export var drag = Vector3()
var lift_dir = Vector3()
var drag_dir = Vector3()
var vel_sq : float
var vel: float
var cl: float
var cd: float
var attack_angle_deg: float
var flow_velocity: Vector3
var local_vel_y : float

# Called when the node enters the scene tree for the first time.
func _ready():
	#DebugOverlay.draw.add_vector(self, "linear_velocity", 1, Color.black)
	start = true
	DebugOverlay.draw.add_value(self, "local_vel_y")
	apply_central_impulse(global_transform.basis.xform(Vector3(0, 10, -2000)))

func _process(delta):
	roll = 0
	pitch = 0
	
	if Input.is_key_pressed(KEY_SPACE):
		apply_central_impulse(global_transform.basis.xform(Vector3(0, 10, -200)))
	if Input.is_action_pressed("ui_left"):
		roll = -roll_speed
	if Input.is_action_pressed("ui_right"):
		roll = roll_speed

	if Input.is_action_pressed("ui_up"):
		pitch = -pitch_speed
	if Input.is_action_pressed("ui_down"):
		pitch = pitch_speed

func _integrate_forces(state):
	if (start):
		state.apply_central_impulse(Vector3(0, 0, 0))
		start = false

	var wind = Vector3(5, 10, 0)

	#var air_foil = $Wings
	# linear_velocity is the global velocity
	#var flow_velocity = -linear_velocity + wind - angular_velocity.cross(air_foil.transform.origin)
	add_torque(transform.basis.xform(Vector3(pitch, yaw, -roll) * state.step))
	#for air_foil in $AirFoils.get_children():
	var air_foil = $Wings
	flow_velocity = -global_transform.basis.xform_inv(linear_velocity) - global_transform.basis.xform_inv(angular_velocity).cross(air_foil.transform.origin)
	local_vel_y = -flow_velocity.y
	air_foil.do_update(state, flow_velocity, transform.origin)


