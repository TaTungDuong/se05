extends Node2D

const chuc_nang = [
	"Sign In ",
	"Sign Up",
	
]

func _ready():
	set_tab_title()
	if DB.check_remembered_account() == true:
		_on_transition_animation_finished("trans_out")
	else:
		$Transition.play("trans_in")

func set_tab_title():
	$ChucNang.tabs_visible = false
	for i in range($ChucNang.get_child_count()):
		$ChucNang.set_tab_title(i, chuc_nang[i])

func _on_dang_nhap_signup_pressed():
	$ChucNang.current_tab = 1

func _on_dang_nhap_signin_finished():
	$Transition.play("trans_out")

func _on_dang_ky_signin_pressed():
	$ChucNang.current_tab = 0

@onready var transition = $Transition
var next_scene = "res://scenes/modules/module0/home.tscn"
func _on_transition_animation_finished(anim_name):
	if anim_name == "trans_out":
		Effect.generate_loading(self, next_scene)


