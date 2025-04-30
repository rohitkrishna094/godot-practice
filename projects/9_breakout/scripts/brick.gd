extends RigidBody2D

@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D

func hit():
	cpu_particles_2d.emitting = true
	$Sprite2D.visible = false
	$CollisionShape2D.disabled = true
	GameManager.addPoints(1)
	
	var bricksLeft = get_tree().get_nodes_in_group("Brick")
	if bricksLeft.size() == 1:
		get_parent().get_node("Ball").is_active = false
		await get_tree().create_timer(1).timeout
		GameManager.level += 1
		get_tree().reload_current_scene()
	else:
		await get_tree().create_timer(1).timeout
		queue_free()
