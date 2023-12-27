extends PanelContainer

@onready var accept = $AcceptDialog

@onready var dien_captcha = $VBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/ThongTinNguoiDung/VBoxContainer3/HBoxContainer/DienCaptcha
@onready var mau_captcha = $VBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/ThongTinNguoiDung/VBoxContainer3/HBoxContainer/MauCaptcha

func _ready():
	Captcha.generate_captcha(mau_captcha)
	modulate = Color(1, 1, 1, 0)
	visible = false

signal closed
func _on_dong_button_pressed():
	Captcha.generate_captcha(mau_captcha)
	emit_signal("closed")

@onready var chon_chuc_vu = $VBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/ThongTinNguoiDung/ChucVu
func _on_luu_button_pressed():
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	if dien_captcha.text == "":
		accept.dialog_text = "Chưa điền mã Captcha!"
	elif dien_captcha.text != mau_captcha.text:
		accept.dialog_text = "Mã Captcha không chính xác!\nVui lòng kiểm tra lại."
	else:
		accept.dialog_text = "Đổi chức vụ người dùng thành công!"
		var query = "update NguoiDung set ChucVu = " + str(chon_chuc_vu.get_selected_id()) + " where MaNguoiDung = " + DB.current_selected_pk + ";"
		print(query)
		db.query(query)	
		emit_signal("closed")
		dien_captcha.text = ""
	Captcha.generate_captcha(mau_captcha)
	accept.show()


