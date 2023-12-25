extends VBoxContainer

@onready var button_dangnhap = $VBoxContainer/HBoxContainer/PanelContainer/VBoxContainer2/DangNhap
@onready var button_dangky = $VBoxContainer/HBoxContainer/PanelContainer/VBoxContainer2/DangKy
@onready var button_check = $VBoxContainer/HBoxContainer/PanelContainer/CheckButton
@onready var button_nho = $VBoxContainer/HBoxContainer/PanelContainer/NhoButton
var buttons = []

@onready var dien_captcha = $VBoxContainer/HBoxContainer/PanelContainer/VBoxContainer3/HBoxContainer/DienCaptcha
@onready var mau_captcha = $VBoxContainer/HBoxContainer/PanelContainer/VBoxContainer3/HBoxContainer/MauCaptcha
@onready var ten_dang_nhap = $VBoxContainer/HBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/DienTaiKhoan/TenDangNhap
@onready var mat_khau = $VBoxContainer/HBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/DienTaiKhoan/MatKhau
@onready var popup = $Popup/PopupMenu

func _ready():
	buttons = [
		button_check,
		button_dangky,
		button_dangnhap,
		button_nho,
	]
	window_hide()
	attempt_count = 0
	Captcha.generate_captcha(mau_captcha)

func reset_text():
	ten_dang_nhap.text = ""
	mat_khau.text = ""

func set_form(value: bool):
	for b in buttons:
		b.disabled = not value
	ten_dang_nhap.editable = value
	mat_khau.editable = value

func window_hide():
	popup.dialog_text = ""
	popup.hide()

func _on_check_button_toggled(button_pressed):
	mat_khau.secret = not button_pressed

var attempt_count
func _on_dang_nhap_pressed():
	window_hide()
	if ten_dang_nhap.text == "":
		popup.dialog_text = popup.dialog_text + "Chưa điền tên đăng nhập!\n"
	if mat_khau.text == "":
		popup.dialog_text = popup.dialog_text + "Chưa điền mật khẩu!\n"
	if popup.dialog_text != "":
		popup.show()
		Captcha.generate_captcha(mau_captcha)
		if dien_captcha.text == "":
			popup.dialog_text = popup.dialog_text + "Chưa điền mã captcha!\n"
		elif dien_captcha.text != mau_captcha.text:
			popup.dialog_text = popup.dialog_text + "Nhập mã Captcha sai!\n"
		return
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	db.query("select TenDangNhap, MatKhau from NguoiDung")
	var result = db.query_result
	var correct_account = false
	for i in range(result.size()):
		if result[i]["TenDangNhap"] == ten_dang_nhap.text:
			if result[i]["MatKhau"] == mat_khau.text:
				correct_account = true
				if dien_captcha.text == mau_captcha.text:
					_on_signin_finished()
					return
	Captcha.generate_captcha(mau_captcha)
	dien_captcha.text = ""
	attempt_count = attempt_count + 1
	if attempt_count == 5:
		popup.dialog_text = "Bạn đã đăng nhập không thành công 5 lần!\nVui lòng thử lại sau!" 
	elif correct_account == false:
		popup.dialog_text = "Tài khoản chưa chính xác!\nVui lòng kiểm tra lại!\n"
	if dien_captcha.text == "":
		popup.dialog_text = popup.dialog_text + "Chưa điền mã captcha!\n"
	elif dien_captcha.text != mau_captcha.text:
		popup.dialog_text = popup.dialog_text + "Nhập mã Captcha sai!\n"
	popup.dialog_text = popup.dialog_text + "Còn lại " + str(5 - attempt_count) + " lần thử!\n"
	popup.show()

signal signup_pressed
func _on_dang_ky_pressed():
	emit_signal("signup_pressed")

func _on_popup_menu_confirmed():
	if attempt_count == 5:
		get_tree().quit()

signal signin_finished
func _on_signin_finished():
	emit_signal("signin_finished")
	DB.get_current_info(ten_dang_nhap.text)
	print(button_nho.button_pressed)
	if button_nho.button_pressed == true:
		DB.remember_current_account("1")
	else:
		DB.remember_current_account("0")
	set_form(false)
