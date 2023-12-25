extends PanelContainer

@onready var accept = $AcceptDialog

@onready var dien_captcha = $VBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/ThongTinNguoiDung/VBoxContainer3/HBoxContainer/DienCaptcha
@onready var mau_captcha = $VBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/ThongTinNguoiDung/VBoxContainer3/HBoxContainer/MauCaptcha

func _ready():
	Captcha.generate_captcha(mau_captcha)
	modulate = Color(1, 1, 1, 0)
	visible = false

func reset_input():
	mat_khau_cu.text = ""
	mat_khau_moi.text = ""
	nhap_lai.text = ""

@onready var check_button = $VBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/ThongTinNguoiDung/CheckButton
func _on_check_button_toggled(button_pressed):
	check_button.button_pressed = button_pressed
	mat_khau_cu.secret = not check_button.button_pressed
	mat_khau_moi.secret = not check_button.button_pressed
	nhap_lai.secret = not check_button.button_pressed

signal closed
func _on_dong_button_pressed():
	Captcha.generate_captcha(mau_captcha)
	emit_signal("closed")

@onready var mat_khau_cu = $VBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/ThongTinNguoiDung/MatKhauCu
@onready var mat_khau_moi = $VBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/ThongTinNguoiDung/MatKhauMoi
@onready var nhap_lai = $VBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/ThongTinNguoiDung/NhapLaiMatKhau
func _on_luu_button_pressed():
	if check_old_password() == false:
		accept.dialog_text = "Mật khẩu cũ không chính xác!\nVui lòng kiểm tra lại."
	elif mat_khau_moi.text != nhap_lai.text:
		accept.dialog_text = "Mật khẩu mới nhập lại không trùng khớp!\nVui lòng kiểm tra lại."
	elif dien_captcha.text == "":
		accept.dialog_text = "Chưa điền mã Captcha!"
	elif dien_captcha.text != mau_captcha.text:
		accept.dialog_text = "Mã Captcha không chính xác!\nVui lòng kiểm tra lại."
	else:
		accept.dialog_text = "Thay đổi mật khẩu thành công!"
		DB.change_current_password(mat_khau_moi.text)
		var username = DB.current_user["TenDangNhap"]
		DB.get_current_info(username)
		emit_signal("closed")
		reset_input()
	Captcha.generate_captcha(mau_captcha)
	accept.show()

func check_old_password() -> bool:
	if DB.current_user["MatKhau"] != mat_khau_cu.text:
		return false
	return true

