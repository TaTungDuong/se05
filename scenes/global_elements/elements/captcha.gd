extends Node2D

func generate_captcha(captcha):
	randomize()
	captcha.text = ""
	var characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	for i in range(6):
		captcha.text += characters[randi() % len(characters)]
