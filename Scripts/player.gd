extends Area2D

@export var polygon : Polygon2D

func _ready():
	polygon = get_parent().get_node("PlayerPolygon")

func _physics_process(delta):
	pass
