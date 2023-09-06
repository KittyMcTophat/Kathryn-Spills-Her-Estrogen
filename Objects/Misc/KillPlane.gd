extends Area3D
class_name KillPlane

func _ready():
	body_entered.connect(_body_entered);

func _body_entered(body) -> void:
	if body is Kathryn:
		body.die();
