extends PanelContainer

@onready var node_chucnang = $VBoxContainer/ChucNang
@onready var node_thanhcongcu = $VBoxContainer/ThanhCongCu

func  _ready():
	readDataFromDB()
	_on_chuc_nang_tab_selected(0)

func _on_chuc_nang_tab_selected(tab):
	var current_tab = node_chucnang.get_child(tab)
	if current_tab.has_method("readDataFromDB"):
		current_tab.call_deferred("readDataFromDB", current_tab.query_select_all)
	if current_tab.has_method("reset_tables"):
		current_tab.call_deferred("reset_tables")

func update_toggle(button_name: String):
	for c in node_thanhcongcu.get_children():
		if c.name != button_name:
			c.button_pressed = false
		else:
			c.button_pressed = true

func _on_man_hinh_chinh_pressed():
	node_chucnang.current_tab = 0
	update_toggle("ManHinhChinh")
func _on_lich_cong_viec_pressed():
	node_chucnang.current_tab = 1
	update_toggle("LichCongViec")
func _on_lich_su_pressed():
	node_chucnang.current_tab = 2
	update_toggle("BieuMau")
func _on_lien_he_pressed():
	node_chucnang.current_tab = node_chucnang.get_child_count() - 1
	update_toggle("LienHe")

@onready var so_luong_nhan_khau = $VBoxContainer/ChucNang/ManHinhChinh/ScrollContainer/VBoxContainer/NhanKhau/HBoxContainer/VBoxContainer/SoLuong
@onready var so_luong_ho_khau = $VBoxContainer/ChucNang/ManHinhChinh/ScrollContainer/VBoxContainer/HoKhau/HBoxContainer/VBoxContainer/SoLuong
@onready var so_luong_tam_tru = $VBoxContainer/ChucNang/ManHinhChinh/ScrollContainer/VBoxContainer/TamTruTamVang/HBoxContainer/TamTru/HBoxContainer/VBoxContainer/SoLuong
@onready var so_luong_tam_vang = $VBoxContainer/ChucNang/ManHinhChinh/ScrollContainer/VBoxContainer/TamTruTamVang/HBoxContainer/TamVang/HBoxContainer/VBoxContainer/SoLuong
func readDataFromDB():
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	
	db.query("select * from NhanKhau;")
	so_luong_nhan_khau.text = str(db.query_result.size())
	db.query("select * from HoKhau;")
	so_luong_ho_khau.text = str(db.query_result.size())
	db.query("select * from TamTru;")
	so_luong_tam_tru.text = str(db.query_result.size())
	db.query("select * from TamVang;")
	so_luong_tam_vang.text = str(db.query_result.size())









