extends Node2D

@onready var node_chucnang = $HBoxContainer/VBoxContainer/HBoxContainer/ChucNang
@onready var node_thanhcongcu = $HBoxContainer/VBoxContainer/HBoxContainer/ThanhCongCu/ThanhCongCu/ThanhCongCu
@onready var danh_sach_nguoi_dung = $HBoxContainer/VBoxContainer/HBoxContainer/ChucNang/QuanLyTaiKhoan/VBoxContainer/ChucNang/DanhSachNguoiDung
@onready var trang_chu = $HBoxContainer/VBoxContainer/HBoxContainer/ChucNang/TrangChu
func _ready():
	_on_trang_chu_pressed()

func update_toggle(button_name: String):
	for c in node_thanhcongcu.get_children():
		if c is Button:
			if c.name != button_name:
				c.button_pressed = false
			else:
				c.button_pressed = true

func _on_tai_khoan_pressed():
	node_chucnang.current_tab = node_chucnang.get_tab_count() - 1
	update_toggle("TaiKhoan")
func _on_trang_chu_pressed():
	node_chucnang.current_tab = 0
	update_toggle("TrangChu")
	trang_chu.readDataFromDB()
func _on_ho_khau_pressed():
	node_chucnang.current_tab = 1
	update_toggle("HoKhau")
func _on_thu_chi_pressed():
	node_chucnang.current_tab = 2
	update_toggle("ThuChi")
func _on_phan_thuong_pressed():
	node_chucnang.current_tab = 3
	update_toggle("PhanThuong")

@onready var popup = $Popup/PopupMenu
@onready var confirm = $Popup/ConfirmationDialog
@onready var accept = $Popup/AcceptDialog
@onready var file = $Popup/FileDialog
@onready var avatar = $Popup/Avatar
func _on_hinh_dai_dien_pressed():
	if $Popup/HoSoNguoiDung.visible == false and $Popup/DoiMatKhau.visible == false:
		avatar.visible = not avatar.visible
		$Popup/Avatar/VBoxContainer/HBoxContainer/VBoxContainer/HoVaTen.text = DB.current_user["HoVaTen"]
		$Popup/Avatar/VBoxContainer/HBoxContainer/VBoxContainer/TenDangNhap.text = DB.current_user["TenDangNhap"]

var next_scene = "res://scenes/modules/module0/man_hinh_bat_dau.tscn"
func _on_dang_xuat_pressed():
	avatar.visible = false
	confirm.dialog_text = "Bạn muốn đăng xuất?"
	confirm.show()

func _on_confirmation_dialog_confirmed():
	if confirm.dialog_text == "Bạn muốn đăng xuất?":
		DB.remember_current_account("0")
		Effect.generate_loading(self, next_scene)

func _on_ho_so_nguoi_dung_closed():
	var tween = create_tween()
	tween.tween_property(
		$Popup/HoSoNguoiDung,
		"position",
		Vector2(424, 0),
		0.5,
	).from_current(	
		).set_ease(
		Tween.EASE_IN_OUT
	).set_trans(
		Tween.TRANS_LINEAR
	)
	tween.tween_property(
		$Popup/HoSoNguoiDung,
		"modulate",
		Color(1, 1, 1, 0),
		0.5,
	).from_current(	
		).set_ease(
		Tween.EASE_IN_OUT
	).set_trans(
		Tween.TRANS_LINEAR
	)
	await tween.finished
	$Popup/HoSoNguoiDung.visible = false
	danh_sach_nguoi_dung.call_deferred("_on_lam_moi_button_pressed")

func _on_thong_tin_pressed():
	avatar.visible = false
	$Popup/HoSoNguoiDung.visible = true
	var tween = create_tween()
	tween.tween_property(
		$Popup/HoSoNguoiDung,
		"modulate",
		Color(1, 1, 1, 1),
		0.5,
	).from_current(	
		).set_ease(
		Tween.EASE_IN_OUT
	).set_trans(
		Tween.TRANS_LINEAR
	)
	tween.tween_property(
		$Popup/HoSoNguoiDung,
		"position",
		Vector2(424, 128),
		0.5,
	).from_current(	
		).set_ease(
		Tween.EASE_IN_OUT
	).set_trans(
		Tween.TRANS_LINEAR
	)

func _on_doi_mat_khau_closed():
	var tween = create_tween()
	tween.tween_property(
		$Popup/DoiMatKhau,
		"position",
		Vector2(448, 0),
		0.5,
	).from_current(	
		).set_ease(
		Tween.EASE_IN_OUT
	).set_trans(
		Tween.TRANS_LINEAR
	)
	tween.tween_property(
		$Popup/DoiMatKhau,
		"modulate",
		Color(1, 1, 1, 0),
		0.5,
	).from_current(	
		).set_ease(
		Tween.EASE_IN_OUT
	).set_trans(
		Tween.TRANS_LINEAR
	)
	await tween.finished
	$Popup/DoiMatKhau.visible = false
	danh_sach_nguoi_dung.call_deferred("_on_lam_moi_button_pressed")

func _on_doi_mat_khau_pressed():
	avatar.visible = false
	$Popup/DoiMatKhau.visible = true
	var tween = create_tween()
	tween.tween_property(
		$Popup/DoiMatKhau,
		"modulate",
		Color(1, 1, 1, 1),
		0.5,
	).from_current(	
		).set_ease(
		Tween.EASE_IN_OUT
	).set_trans(
		Tween.TRANS_LINEAR
	)
	tween.tween_property(
		$Popup/DoiMatKhau,
		"position",
		Vector2(448, 128),
		0.5,
	).from_current(	
		).set_ease(
		Tween.EASE_IN_OUT
	).set_trans(
		Tween.TRANS_LINEAR
	)
