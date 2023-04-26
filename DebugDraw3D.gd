extends Control

var font

class Value:
	var object
	var pos
	var property
	var color
	var font
	
	func _init(_font, _pos, _object, _property, _color):
		font = _font
		pos = _pos
		object = _object
		property = _property
		color = _color
	
	func draw(node):
		node.draw_string(font, pos, property + ": " + String(object.get(property)), color)

class Vector:
	var object # Node to follow
	var property # Property to draw
	var scale # Scale factor
	var width # Line width
	var color # Draw dolor
	
	func _init(_object, _property, _scale, _width, _color):
		object = _object
		property = _property
		scale = _scale
		width = _width
		color = _color

	func draw(node, camera):
		var start = camera.unproject_position(object.global_transform.origin)
		var end = camera.unproject_position(object.global_transform.origin + object.get(property) * scale)
		node.draw_line(start, end, color, width)
		node.draw_triangle(end, start.direction_to(end), width * 2, color)

var vectors = [] # Hold all registered values
var values = []

func draw_triangle(pos, dir, size, color):
	var a = pos + dir * size
	var b = pos + dir.rotated(2*PI/3) * size
	var c = pos + dir.rotated(4*PI/3) * size
	var points = PoolVector2Array([a, b, c])
	draw_polygon(points, PoolColorArray([color]))

func _ready():
	var label = Label.new()
	font = label.get_font("")
	label.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not visible:
		return
	update()

func _draw():
	var camera = get_viewport().get_camera()
	for vector in vectors:
		vector.draw(self, camera)
	
	for value in values:
		value.draw(self)
	
func add_vector(object, property, scale, color):
	vectors.append(Vector.new(object, property, scale, 4, color))

func add_value(object, property):
	values.append(Value.new(font, Vector2(10, 100 + values.size() * font.get_height()), object, property, Color.black))
