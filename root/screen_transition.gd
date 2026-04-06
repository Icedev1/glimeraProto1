extends CanvasLayer

@onready var anim = $AnimationPlayer

var is_transitioning = false

func play(anim_name: String, mid_callback: Callable):
	if is_transitioning:
		return
	
	is_transitioning = true
	
	print("TRANSITION START")
	
	anim.play(anim_name + "_out")
	await anim.animation_finished
	
	print("MIDPOINT")
	
	if mid_callback:
		mid_callback.call()
	
	anim.play(anim_name + "_in")
	await anim.animation_finished
	
	print("TRANSITION END")
	
	is_transitioning = false
