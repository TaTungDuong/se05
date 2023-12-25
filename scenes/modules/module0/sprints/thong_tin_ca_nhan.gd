extends VBoxContainer

const tableName = "NguoiDung"
const query_select_all = "select * from NhanKhau where MaNhanKhau = ID;"

func _ready():
	Effect.set_ngay_sinh(nam_sinh_nguoi_dung, thang_sinh_nguoi_dung, ngay_sinh_nguoi_dung)
	Effect.set_ngay_sinh(nam_sinh_nhan_khau, thang_sinh_nhan_khau, ngay_sinh_nhan_khau)
	_on_sua_check_button_toggled(false)
	readDataFromDB(query_select_all)

@onready var nhan_khau_box = $HBoxContainer/VBoxContainer2/PanelContainer/ScrollContainer/VBoxContainer/NhanKhau
func _on_buffer_hien_thi_button_toggled(button_pressed: bool):
	nhan_khau_box.visible = button_pressed

@onready var nam_sinh_nhan_khau = $HBoxContainer/VBoxContainer2/PanelContainer/ScrollContainer/VBoxContainer/NhanKhau/ThongTinNhanKhau/NgaySinh/NamSinh
@onready var thang_sinh_nhan_khau = $HBoxContainer/VBoxContainer2/PanelContainer/ScrollContainer/VBoxContainer/NhanKhau/ThongTinNhanKhau/NgaySinh/ThangSinh
@onready var ngay_sinh_nhan_khau = $HBoxContainer/VBoxContainer2/PanelContainer/ScrollContainer/VBoxContainer/NhanKhau/ThongTinNhanKhau/NgaySinh/NgaySinh
@onready var gioi_tinh_nhan_khau = $HBoxContainer/VBoxContainer2/PanelContainer/ScrollContainer/VBoxContainer/NhanKhau/ThongTinNhanKhau/GioiTinh

@onready var nam_sinh_nguoi_dung = $HBoxContainer/VBoxContainer2/PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer/ThongTinNguoiDung/NgaySinh/NamSinh
@onready var thang_sinh_nguoi_dung = $HBoxContainer/VBoxContainer2/PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer/ThongTinNguoiDung/NgaySinh/ThangSinh
@onready var ngay_sinh_nguoi_dung = $HBoxContainer/VBoxContainer2/PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer/ThongTinNguoiDung/NgaySinh/NgaySinh

@onready var ho_va_ten_avatar = $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/HoVaTen
@onready var ten_dang_nhap_avatar = $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/TenDangNhap
@onready var truong_thong_tin_nguoi_dung = $HBoxContainer/VBoxContainer2/PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer/TruongThongTin
@onready var thong_tin_nguoi_dung = $HBoxContainer/VBoxContainer2/PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer/ThongTinNguoiDung
@onready var gioi_tinh_nguoi_dung = $HBoxContainer/VBoxContainer2/PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer/ThongTinNguoiDung/GioiTinh
@onready var chuc_vu_nguoi_dung = $HBoxContainer/VBoxContainer2/PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer/ThongTinNguoiDung/ChucVu
@onready var thong_tin_nhan_khau = $HBoxContainer/VBoxContainer2/PanelContainer/ScrollContainer/VBoxContainer/NhanKhau/ThongTinNhanKhau
func readDataFromDB(query):
	ho_va_ten_avatar.text = DB.current_user["HoVaTen"]
	ten_dang_nhap_avatar.text = DB.current_user["TenDangNhap"]
	
	for f in thong_tin_nguoi_dung.get_children():
		if "Buffer" not in f.name:
			if f.name == "NgaySinh":
				var dict = Effect.extract_date(DB.current_user[f.name])
				nam_sinh_nguoi_dung.select(dict["nam"] + 1 - 1900)
				thang_sinh_nguoi_dung.select(dict["thang"])
				ngay_sinh_nguoi_dung.select(dict["ngay"])
			elif f.name == "GioiTinh":
				gioi_tinh_nguoi_dung.select(int(DB.current_user[f.name]) + 1)
			elif f.name == "ChucVu":
				chuc_vu_nguoi_dung.select(int(DB.current_user[f.name]) + 1)
			elif DB.current_user[f.name] == null:
				f.text = ""
			else:
				f.text = str(DB.current_user[f.name])
	if "null" in str(DB.current_user["MaNhanKhau"]):
		return
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	
	query = query_select_all
	query = query.replace("ID", str(DB.current_user["MaNhanKhau"]))
	db.query(query)
	if db.query_result.size() == 0:
		return
	var result = db.query_result
	for f in thong_tin_nhan_khau.get_children():
		if "Buffer" not in f.name:
			if f.name == "NgaySinh":
				var dict = Effect.extract_date(result[0][f.name])
				nam_sinh_nhan_khau.select(dict["nam"] + 1 - 1900)
				thang_sinh_nhan_khau.select(dict["thang"])
				ngay_sinh_nhan_khau.select(dict["ngay"])
			elif f.name == "GioiTinh":
				gioi_tinh_nhan_khau.select(int(result[0][f.name]) + 1)
			elif result[0][f.name] == null:
					f.text = ""
			else:
				f.text = str(result[0][f.name])

@onready var luu_button = $HBoxContainer/VBoxContainer2/HBoxContainer/LuuButton
@onready var captcha_box = $HBoxContainer/VBoxContainer2/PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer/ThongTinNguoiDung/BufferCaptchaBox
@onready var mau_captcha = $HBoxContainer/VBoxContainer2/PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer/ThongTinNguoiDung/BufferCaptchaBox/HBoxContainer/MauCaptcha
@onready var dien_captcha = $HBoxContainer/VBoxContainer2/PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer/ThongTinNguoiDung/BufferCaptchaBox/HBoxContainer/DienCaptcha
@onready var sua_button = $HBoxContainer/VBoxContainer/SuaCheckButton
func _on_sua_check_button_toggled(button_pressed: bool):
	luu_button.visible = button_pressed
	captcha_box.visible = button_pressed
	Captcha.generate_captcha(mau_captcha)
	readDataFromDB(query_select_all)
	for f in thong_tin_nguoi_dung.get_children():
		if "Buffer" not in f.name and "ChucVu" not in f.name:
			if f.name == "NgaySinh":
				for c in f.get_children():
					c.disabled = not button_pressed
			elif f.name == "GioiTinh":
				f.disabled = not button_pressed
			else:
				f.editable = button_pressed

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
			info[f.name] = Effect.check_date_valid(
				nam_sinh_nguoi_dung.get_selected_id(), 
				thang_sinh_nguoi_dung.get_selected_id(), 
				ngay_sinh_nguoi_dung.get_selected_id()
				)
			if info[f.name] == null:
				valid = false
				accept.dialog_text += "Ngày sinh không hợp lệ!\n"
		elif "Buffer" not in f.name and "ChucVu" not in f.name:
			if f.text.replace(" ", "") == "":
				var fname = f.name
				if "*" in truong_thong_tin_nguoi_dung.get_node(fname).text:
					accept.dialog_text += "Chưa điền thông tin " + truong_thong_tin_nguoi_dung.get_node(fname).text.to_lower().replace("*", "") + "!\n"
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
		sua_button.button_pressed = false
		dien_captcha.text = ""
	Captcha.generate_captcha(mau_captcha)
	accept.show()
	
func _on_lam_moi_button_pressed():
	readDataFromDB(query_select_all)












