extends KinematicBody

var velocity : Vector3
var angular_velocity : Vector3
var flow : Vector3
var attack : float
export var mass = 170
export var gravity = 9.8
var lift : Vector3
var drag : Vector3
var thrust : Vector3
export var pitch_speed = 40
export var max_pitch = 60
var pitch = 0
export var roll_speed = 20
export var max_roll = 20
var roll = 0
var yaw_speed = 100
var yaw_velocity : float
var yaw = 0
var lift_factor
# Called when the node enters the scene tree for the first time.
func _ready():

	DebugOverlay.draw.add_value(self, "lift_factor")



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _physics_process(delta):
	var angular_velocity_factor = -roll / max_roll
	print(angular_velocity_factor)
	yaw_velocity = angular_velocity_factor * yaw_speed
	yaw += yaw_velocity * delta
	if (roll != 0):
		roll += -1 * sign(roll) * min(abs(roll), roll_speed * 0.01 * delta)
	
	transform.basis = Basis().rotated(Vector3.RIGHT, pitch).rotated(Vector3.FORWARD, -roll).rotated(Vector3.UP, -yaw)
	
	velocity += mass * gravity * transform.basis.xform(Vector3.DOWN) * delta
	flow = -velocity
	flow.x = 0
	
	lift_factor = global_transform.basis.y.dot(Vector3.UP)
	lift = lift_factor * 0.1 * Vector3.UP

	var thrust_factor = (-global_transform.basis.z).dot(Vector3.DOWN)
	thrust = lerp(lift_factor, thrust_factor, 0.8) * 0.001 * Vector3.FORWARD

	drag = thrust_factor * 0.000000001 * Vector3.BACK * velocity.length()


	var velocity_change = (lift + drag + thrust)
	velocity += velocity_change
	handle_input(delta)
	move_and_collide(global_transform.xform(velocity) * delta)
	transform = transform.orthonormalized()
	
func handle_input(delta):
	if Input.is_key_pressed(KEY_SPACE):
		velocity.z += -100
	if Input.is_action_pressed("ui_left") and roll < deg2rad(max_roll):
		roll += deg2rad(roll_speed) * delta
	if Input.is_action_pressed("ui_right") and roll > deg2rad(-max_roll):
		roll  += -deg2rad(roll_speed) * delta

	if Input.is_action_pressed("ui_up") and pitch > deg2rad(-max_pitch):
		pitch += -deg2rad(pitch_speed) * delta
	if Input.is_action_pressed("ui_down") and pitch < deg2rad(max_pitch):
		pitch += deg2rad(pitch_speed) * delta
