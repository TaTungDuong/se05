extends VBoxContainer

const tableName = "NguoiDung"
const query_select_all = "select * from NhanKhau where MaNhanKhau = ID;"

func _ready():
	readDataFromDB(query_select_all)

@onready var ho_va_ten_avatar = $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/HoVaTen
@onready var ten_dang_nhap_avatar = $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/TenDangNhap
func readDataFromDB(_query):
	ho_va_ten_avatar.text = DB.current_user["HoVaTen"]
	ten_dang_nhap_avatar.text = DB.current_user["TenDangNhap"]
	Captcha.generate_captcha(mau_captcha)

@onready var thong_tin_nguoi_dung = $HBoxContainer/VBoxContainer2/PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer/ThongTinNguoiDung
func _on_buffer_hien_thi_button_toggled(button_pressed: bool):
	for f in thong_tin_nguoi_dung.get_children():
		if "Buffer" not in f.name:
			f.secret = not button_pressed

@onready var luu_button = $HBoxContainer/VBoxContainer2/HBoxContainer/LuuButton
@onready var captcha_box = $HBoxContainer/VBoxContainer2/PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer/ThongTinNguoiDung/BufferCaptchaBox
@onready var mau_captcha = $HBoxContainer/VBoxContainer2/PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer/ThongTinNguoiDung/BufferCaptchaBox/HBoxContainer/MauCaptcha
@onready var dien_captcha = $HBoxContainer/VBoxContainer2/PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer/ThongTinNguoiDung/BufferCaptchaBox/HBoxContainer/DienCaptcha

@onready var mat_khau_cu = $HBoxContainer/VBoxContainer2/PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer/ThongTinNguoiDung/MatKhauCu
@onready var mat_khau_moi = $HBoxContainer/VBoxContainer2/PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer/ThongTinNguoiDung/MatKhauMoi
@onready var nhap_lai = $HBoxContainer/VBoxContainer2/PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer/ThongTinNguoiDung/NhapLai
@onready var accept = $AcceptDialog
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
		readDataFromDB(query_select_all)
		reset_input()
	Captcha.generate_captcha(mau_captcha)
	accept.show()

func _on_lam_moi_button_pressed():
	readDataFromDB(query_select_all)


func reset_input():
	dien_captcha.text = ""
	mat_khau_cu.text = ""
	mat_khau_moi.text = ""
	nhap_lai.text = ""

func check_old_password() -> bool:
	if DB.current_user["MatKhau"] != mat_khau_cu.text:
		return false
	return true









