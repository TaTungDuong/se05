extends PanelContainer

@onready var dien_captcha = $VBoxContainer/PanelContainer/VBoxContainer3/HBoxContainer/DienCaptcha
@onready var mau_captcha = $VBoxContainer/PanelContainer/VBoxContainer3/HBoxContainer/MauCaptcha

func _ready():
	Captcha.generate_captcha(mau_captcha)
	Effect.set_ngay_sinh(dien_nam, dien_thang, dien_ngay)
	modulate = Color(1, 1, 1, 0)
	visible = false

@onready var thong_tin_nguoi_dung = $VBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/ThongTinNguoiDung
func get_info():
	for f in thong_tin_nguoi_dung.get_children():
		if f.name == "GioiTinh":
			f.select(DB.current_user[f.name] + 1)
		elif f.name == "NgaySinh":
			var dict = Effect.extract_date(DB.current_user["NgaySinh"])
			dien_nam.select(dict["nam"] + 1 - 1900)
			dien_thang.select(dict["thang"])
			dien_ngay.select(dict["ngay"])
		elif "Buffer" not in f.name:
			if DB.current_user[f.name] == null:
				f.text = ""
			else:
				f.text = str(DB.current_user[f.name])

func _process(_delta):
	if modulate == Color(1, 1, 1, 0):
		get_info()

signal closed
func _on_dong_button_pressed():
	Captcha.generate_captcha(mau_captcha)
	emit_signal("closed")

@onready var accept = $AcceptDialog
func _on_luu_button_pressed():
	accept.dialog_text = ""
	var valid = true
	var info: Dictionary = Dictionary()
	for f in thong_tin_nguoi_dung.get_children():
		if f.name == "GioiTinh":
			info[f.name] = f.get_selected_id()
			if info[f.name] != 0 and info[f.name] != 1:
				valid = false
				accept.dialog_text += "Chưa điền thông tin giới tính!\n"
		elif f.name == "NgaySinh":
			info[f.name] = Effect.check_date_valid(dien_nam.get_selected_id(), dien_thang.get_selected_id(), dien_ngay.get_selected_id())
			if info[f.name] == null:
				valid = false
				accept.dialog_text += "Ngày sinh không hợp lệ!\n"
		elif f.name == "HoVaTen":
			info[f.name] = str(f.text)
			if f.text == "":
				valid = false
				accept.dialog_text += "Chưa điền thông tin họ và tên!\n"
		elif "Buffer" not in f.name:
			if f.text == "":
				info[f.name] = null
			else:
				info[f.name] = str(f.text)
	if dien_captcha.text != mau_captcha.text:
		valid = false
		if dien_captcha.text == "":
			accept.dialog_text = "Chưa điền captcha!"
		else:
			accept.dialog_text = "Mã Captcha không chính xác!\nVui lòng kiểm tra lại."
	if valid == true:
		accept.dialog_text = "Thay đổi thông tin người dùng thành công!"
		DB.update_current_info(info)
		emit_signal("closed")
	Captcha.generate_captcha(mau_captcha)
	accept.show()

@onready var dien_nam = $VBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/ThongTinNguoiDung/NgaySinh/Nam
@onready var dien_thang = $VBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/ThongTinNguoiDung/NgaySinh/Thang
@onready var dien_ngay = $VBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/ThongTinNguoiDung/NgaySinh/Ngay

