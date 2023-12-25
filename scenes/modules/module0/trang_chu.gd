extends PanelContainer

func _ready():
	readDataFromDB()

@onready var so_luong_nhan_khau = $VBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/VBoxContainer/NhanKhau/HBoxContainer/VBoxContainer/SoLuong
@onready var so_luong_ho_khau = $VBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/VBoxContainer/HoKhau/HBoxContainer/VBoxContainer/SoLuong
@onready var so_luong_tam_tru = $VBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/VBoxContainer/TamTruTamVang/HBoxContainer/TamTru/HBoxContainer/VBoxContainer/SoLuong
@onready var so_luong_tam_vang = $VBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/VBoxContainer/TamTruTamVang/HBoxContainer/TamVang/HBoxContainer/VBoxContainer/SoLuong
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









