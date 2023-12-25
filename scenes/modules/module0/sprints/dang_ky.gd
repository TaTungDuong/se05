extends VBoxContainer

@onready var popup = $Popup/PopupMenu

func _on_dang_ky_pressed():
	window_hide()
	_on_form_filled_in()

signal signin_pressed
func _on_dang_nhap_pressed():
	emit_signal("signin_pressed")

func _on_check_button_buffer_toggled(button_press):
	mat_khau.secret = not button_press
	
func _ready():
	Captcha.generate_captcha(mau_captcha)
	mat_khau.secret = true
	Effect.set_ngay_sinh(dien_nam, dien_thang, dien_ngay)

func window_hide():
	popup.dialog_text = ""
	popup.hide()

@onready var dien_nam = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer/DienTaiKhoan/NgaySinh/DienNam
@onready var dien_thang = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer/DienTaiKhoan/NgaySinh/DienThang
@onready var dien_ngay = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer/DienTaiKhoan/NgaySinh/DienNgay

@onready var form = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer/DienTaiKhoan
@onready var fields = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer/Icon
@onready var dien_gioitinh = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer/DienTaiKhoan/GioiTinh
@onready var ten_dang_nhap = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer/DienTaiKhoan/TenDangNhap
@onready var mat_khau = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer/DienTaiKhoan/MatKhau
@onready var dien_captcha = $VBoxContainer/HBoxContainer/PanelContainer/VBoxContainer3/HBoxContainer/DienCaptcha
@onready var mau_captcha = $VBoxContainer/HBoxContainer/PanelContainer/VBoxContainer3/HBoxContainer/MauCaptcha
func _on_form_filled_in():
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	
	var valid = true
	var info : Dictionary = Dictionary()
	var result
	db.query("PRAGMA table_info(NguoiDung);")
	result = db.query_result
	for f in result:
		if f["name"] != "MaNguoiDung":
			if f["name"] == "NgaySinh":
				var nam = dien_nam.get_selected_id()
				var thang = dien_thang.get_selected_id()
				var ngay = dien_ngay.get_selected_id()
				info[f["name"]] = Effect.check_date_valid(nam, thang, ngay)
				if Effect.check_date_valid(nam, thang, ngay) == null:
					valid = false
					popup.dialog_text = popup.dialog_text +  "Ngày sinh không hợp lệ!\n"
			elif f["name"] == "GioiTinh":
				info[f["name"]] = dien_gioitinh.get_selected_id()
				if info[f["name"]] != 0 and info[f["name"]] != 1:
					valid = false
					popup.dialog_text = popup.dialog_text + "Chưa điền thông tin giới tính!\n"
			elif f["name"] == "ChucVu":
				info[f["name"]] = "2"
			elif f["name"] == "NhoTaiKhoan":
				info[f["name"]] = "0"
			else :
				info[f["name"]] = form.get_node(f["name"]).text
				if info[f["name"]] == "":
					info[f["name"]] = null
				if info[f["name"]] == null and f["name"] != "GhiChu":
					valid = false
					popup.dialog_text = popup.dialog_text +  "Chưa điền thông tin " + fields.get_node(f["name"]).text.to_lower() + "!\n"
	if dien_captcha.text == "":
		popup.dialog_text = popup.dialog_text + "Chưa điền mã captcha!\n"
		valid = false
	elif dien_captcha.text != mau_captcha.text:
		popup.dialog_text = popup.dialog_text + "Nhập mã Captcha sai!\n"
		valid = false
	release_focus_form()
	Captcha.generate_captcha(mau_captcha)
	dien_captcha.text = ""
	if valid == false or check_valid_form() == false:
		popup.show()
	else:
		reset_form()
		db.insert_row("NguoiDung", info)
		popup.dialog_text = "Đăng ký thành công!\nVui lòng đăng nhập để xác nhận tài khoản."
		popup.show()
		emit_signal("signin_pressed")

func check_valid_form():
	window_hide()
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	db.query("select TenDangNhap, MatKhau from NguoiDung")
	var result = db.query_result
	for i in range(result.size()):
		if result[i]["TenDangNhap"] == ten_dang_nhap.text:
			popup.dialog_text = "Tên đăng nhập này đã tồn tại!"
			break
	if popup.dialog_text != "":
		return false
	return true

func reset_form():
	for f in form.get_children():
		dien_gioitinh.select(0)
		dien_nam.select(0)
		dien_thang.select(0)
		dien_ngay.select(0)
		if f.name != "GioiTinh" and f.name != "NgaySinh":
			if "Buffer" not in f.name:
				f.text = ""
func release_focus_form():
	for f in form.get_children():
		dien_gioitinh.release_focus()
		dien_nam.release_focus()
		dien_thang.release_focus()
		dien_ngay.release_focus()
		if f.name != "GioiTinh" and f.name != "NgaySinh":
			if "Buffer" not in f.name:
				f.release_focus()










