extends Area3D
class_name KillPlane

func _ready():
	body_entered.connect(_body_entered);

func _body_entered(body) -> void:
	if body is Kathryn && !(body.state is DeathState):
		Log.print_info(str(self) + " killing player " + str(body));
		body.die();
