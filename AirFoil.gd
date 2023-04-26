extends Spatial

var lift = Vector3()
var drag = Vector3()
var lift_dir = Vector3()
var drag_dir = Vector3()
var vel_sq : float
var vel: float
var cl: float
var cd: float
var air_pressure = 14.7 / (2.204623 * pow(0.01 * 2.54, 2))
var force: Vector3
var torque: Vector3
export var k = 0.001
var local_flow_velocity : Vector3
var area : float
var attack_angle_deg : float
var drag_force : float
var lift_force : float
var local_flow_vel : float
var aspect_ratio : float
var wingspan : float
var chord_length : float
var last_vel : Vector3
var new_vel : Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	wingspan = scale.x * 2
	chord_length = scale.z * 2
	area = wingspan * chord_length
	DebugOverlay.draw.add_value(self, "attack_angle_deg")
	DebugOverlay.draw.add_value(self, "area")
	DebugOverlay.draw.add_value(self, "cl")
	DebugOverlay.draw.add_value(self, "cd")
	DebugOverlay.draw.add_value(self, "lift_force")
	DebugOverlay.draw.add_value(self, "drag_force")
	DebugOverlay.draw.add_value(self, "local_flow_vel")
	DebugOverlay.draw.add_value(self, "aspect_ratio")
	DebugOverlay.draw.add_value(self, "area")

func _process(delta):
	$DebugLayer/LiftArrow.scale.z = lift_force
	$DebugLayer/LiftArrow.look_at(global_transform.xform(lift), Vector3.UP)
	$DebugLayer/DragArrow.scale.z = drag_force
	$DebugLayer/DragArrow.look_at(global_transform.xform(drag), Vector3.UP)
	$DebugLayer/LocalFlowArrow.scale.z = local_flow_velocity.length()
	$DebugLayer/LocalFlowArrow.look_at(global_transform.xform(local_flow_velocity), Vector3.UP)

func unit_step(t):
	return float(t > 0)

func do_update(state : PhysicsDirectBodyState, world_flow_velocity : Vector3, center_of_mass : Vector3):
	var chord = Vector3.FORWARD

	local_flow_velocity = transform.basis.xform_inv(world_flow_velocity)
	local_flow_velocity.x = 0
	new_vel = local_flow_velocity
	local_flow_vel = local_flow_velocity.length()
	
	var flow_angle = atan2(local_flow_velocity.y, local_flow_velocity.z)
	var attack_angle = -flow_angle
	attack_angle_deg = rad2deg(attack_angle)

	var dynamic_pressure = 0.5 * air_pressure * (local_flow_velocity.length_squared())
	var change_vel = new_vel - last_vel

	#  Aspect ratio is defined as the square of the wingspan (b) divided by the planform area of the wing (S) when viewed from above
	aspect_ratio = (wingspan * wingspan) / area
	var lift_coefficient_slope = 2 * PI # max 2 * PI
	cl = -lift_coefficient_slope * (aspect_ratio/(aspect_ratio + 2)) * attack_angle
	
	var cd_min = 0.025 # A good value to use is around 0.025 for subsonic aircraft and 0.045 for aircraft operating faster than the speed of sound.
	var e = 0.8 # Oswald's efficiency factor. The efficiency factor, e, varies for different aircraft, but it doesn't change very much. As a general rule, high-wing planes tend to have an efficiency factor around 0.8 while that of low-wing planes is closer to 0.6. A reasonable average to use for most planes is about 0.75.
	cd = cd_min + ((cl * cl)/(PI * aspect_ratio * e)) # this is a good equation

	var a = abs(rad2deg(attack_angle))
	if (a > 20):
		cl = lerp(0, cl, (180 - a) / 180)

	var drag_direction = global_transform.basis.xform(local_flow_velocity).normalized()
	var lift_direction = drag_direction.cross(global_transform.basis.x)
	lift_force = cl * dynamic_pressure * area
	drag_force = cd * dynamic_pressure * area
	lift = lift_direction * lift_force
	drag = drag_direction * drag_force

	var force = lift + drag
	state.add_central_force((lift + drag) * k * state.step)

	var cm = (cl / 4)
	var torque_force = cm * dynamic_pressure * area
	var torque_1 = transform.basis.x * torque_force * chord_length
	var global_center_of_mass = global_transform.xform(transform.xform_inv(center_of_mass))
	var r = (global_transform.origin - global_center_of_mass).cross(force)
	var torque = r + torque_1

	state.add_torque(torque * k * 0.00001 * state.step)
	transform = transform.orthonormalized();
