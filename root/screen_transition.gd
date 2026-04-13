extends CanvasLayer

@onready var anim = $AnimationPlayer

var is_transitioning = false

func playfade(mid_callback: Callable):
	if is_transitioning:
		return
	
	is_transitioning = true
	
	print("TRANSITION START")
	
	anim.play("fade_out")
	await anim.animation_finished
	
	print("MIDPOINT")
	
	if mid_callback:
		mid_callback.call()
	
	anim.play("fade_in")
	await anim.animation_finished
	
	print("TRANSITION END")
	
	is_transitioning = false

func playclockwipe(mid_callback: Callable):
	if is_transitioning:
		return
	
	is_transitioning = true
	
	anim.play("fade_out",-1,0.5)
	await anim.animation_finished	
	
	if mid_callback:
		mid_callback.call()
	
	anim.play("clock_wipe")
	await anim.animation_finished
	
	is_transitioning = false

func playscreenshatter(mid_callback: Callable):
	if is_transitioning:
		return
	
	is_transitioning = true
	
	anim.play("screenshatter")
	await get_tree().create_timer(0.2).timeout
	
	if mid_callback:
		mid_callback.call()
	
	await anim.animation_finished	

	is_transitioning = false
