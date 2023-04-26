extends KinematicBody

export var initial_velocity: Vector3
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
var yaw_speed = 1
var yaw_velocity : float
var yaw = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	#DebugOverlay.draw.add_vector(self, "lift", 1, Color.blue)
	#DebugOverlay.draw.add_vector(self, "drag", 1, Color.orange)
	#DebugOverlay.draw.add_vector(self, "thrust", 1, Color.green)
	velocity = initial_velocity
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _physics_process(delta):
	var angular_velocity_factor = roll / deg2rad(max_roll)
	$Glider/Pilot.transform.basis = Basis().rotated(Vector3.FORWARD, angular_velocity_factor * deg2rad(18.23)).rotated(Vector3.UP, angular_velocity_factor * deg2rad(23.84))
	print(angular_velocity_factor)
	yaw_velocity = -angular_velocity_factor * yaw_speed
	yaw += yaw_velocity * delta
	if (roll != 0):
		roll += -1 * sign(roll) * min(abs(roll), roll_speed * 0.01 * delta)
		
	
	velocity = velocity.rotated(transform.basis.y, -yaw_velocity * delta)
	transform.basis = Basis().rotated(Vector3.RIGHT, pitch).rotated(Vector3.UP, -yaw)
	$Glider.rotation = Vector3(0, 0, roll)
	
	velocity.y -= mass * gravity * delta
	flow = -velocity
	
	var lift_factor = flow.dot(transform.basis.y)
	lift = lift_factor * 0.4 * Vector3.UP

	var thrust_factor = Vector3.DOWN.dot(-transform.basis.z)
	thrust = lerp(lift_factor, thrust_factor, 0.99) * 0.4 * -transform.basis.z
	thrust.y = 0

	var drag_factor = abs(Vector3.BACK.dot(transform.basis.y))
	drag = lerp(lift_factor, drag_factor, 0.5) * 0.0000008 * transform.basis.z * velocity.length_squared()
	drag.y= 0


	var velocity_change = (lift + drag + thrust) * delta * 100
	velocity += velocity_change
	handle_input(delta)
	move_and_collide(velocity * delta)
	transform = transform.orthonormalized()
	
func handle_input(delta):
	if Input.is_key_pressed(KEY_SPACE):
		velocity += -transform.basis.z * 100 * delta
	if Input.is_action_pressed("ui_left") and roll < deg2rad(max_roll):
		roll += deg2rad(roll_speed) * delta
	if Input.is_action_pressed("ui_right") and roll > deg2rad(-max_roll):
		roll  += -deg2rad(roll_speed) * delta

	if Input.is_action_pressed("ui_up") and pitch > deg2rad(-max_pitch):
		pitch += -deg2rad(pitch_speed) * delta
	if Input.is_action_pressed("ui_down") and pitch < deg2rad(max_pitch):
		pitch += deg2rad(pitch_speed) * delta
