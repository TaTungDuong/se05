extends Node2D

@export var test = 0

var db_name = "res://database/se05"
var sql_file_path = "res://database/se05.sql"
var new_sql_file_path = "res://database/new_se05.sql"
var current_user

func _ready():
	if test == 0:
		get_current_info("se05")
	elif test == 1:
		reset_database()
	elif test == 2:
		create_new_database()

func reset_database():
	var db = SQLite.new()
	db.path = db_name
	db.open_db()
	var sql_file = FileAccess.open(new_sql_file_path, FileAccess.READ)
	var sql_commands = sql_file.get_as_text()
	sql_file.close()

	db.query(sql_commands)
	get_current_info("se05")

func create_new_database():
	var db = SQLite.new()
	db.path = db_name
	db.open_db()
	var sql_file = FileAccess.open(sql_file_path, FileAccess.READ)
	var sql_commands = sql_file.get_as_text()
	sql_file.close()

	db.query(sql_commands)
	get_current_info("se05")


func check_remembered_account() -> bool:
	var db = SQLite.new()
	db.path = db_name
	db.open_db()
	db.query("select TenDangNhap, NhoTaiKhoan from NguoiDung")
	var result = db.query_result
	for i in range(result.size()):
		if result[i]["NhoTaiKhoan"] == 1:
			get_current_info(result[i]["TenDangNhap"])
			return true
	return false

func remember_current_account(value: String):
	var db = SQLite.new()
	db.path = db_name
	db.open_db()
	var query = "update NguoiDung set NhoTaiKhoan = " + value + " where TenDangNhap = \"" + current_user["TenDangNhap"] + "\""
	db.query(query)

func get_current_info(username):
	var db = SQLite.new()
	db.path = db_name
	db.open_db()
	db.query("select * from NguoiDung where TenDangNhap = '" + username + "';")
	print("select * from NguoiDung where TenDangNhap = '" + username + "';")
	print(db.query_result)
	current_user = db.query_result[0]

func change_current_role(value: String):
	var db = SQLite.new()
	db.path = db_name
	db.open_db()
	var query = "update NguoiDung set ChucVu = " + value + " where TenDangNhap = \"" + current_user["TenDangNhap"] + "\""
	db.query(query)

func change_current_password(password: String):
	var db = SQLite.new()
	db.path = db_name
	db.open_db()
	var query = "update NguoiDung set MatKhau = \'" + password + "\' where TenDangNhap = \"" + current_user["TenDangNhap"] + "\""
	db.query(query)

func update_current_info(info: Dictionary):
	var db = SQLite.new()
	db.path = db_name
	db.open_db()
	
	var query = "update NguoiDung set\n"
	for f in info.keys():
		if typeof(info[f]) == TYPE_STRING:
			info[f] = '\'' + info[f] + '\''
		elif typeof(info[f]) == TYPE_INT:
			info[f] = str(info[f])
		elif typeof(info[f]) == TYPE_NIL:
			info[f] = "null"
		query = query + f + '=' + info[f]
		if f != info.keys()[info.size() - 1]:
			query = query + ",\n"
		else:
			query = query + " \n"
	query = query + "where MaNguoiDung = " + str(current_user["MaNguoiDung"]) + ";"
	print(query)
	db.query(query)
	get_current_info(info["TenDangNhap"].replace("\'", ""))

const tableVietnameseName = {
	"NhanKhau": "Nhân khẩu",
	"HoKhau": "Hộ khẩu",
	"TamTru": "Tạm trú",
	"TamVang": "Tạm vắng",
	"ThuPhi": "Thu phí",
	"ChiPhi": "Chi phí",
	"PhanThuongCuoiNamHoc": "Phần thưởng cuối năm học",
	"PhanThuongDipDacBiet": "Phần thưởng dịp đặc biệt",
	"CongViec": "Công việc"
}
func update_current_history(tableName: String, pk: String, info: Dictionary, action: String):
	var db = SQLite.new()
	db.path = db_name
	db.open_db()
	
	if pk == "":
		db.query("select Ma" + tableName + " from " + tableName + ";")
	else:
		db.query("select Ma" + tableName + " from " + tableName + " where Ma" + tableName + " = " + str(pk) + ";")
	var new_history = Dictionary()
	new_history["Ma" + tableName] = str(db.query_result[db.query_result.size() - 1]["Ma" + tableName])
	for f in info.keys():
		new_history[f] = info[f]
		if typeof(new_history[f]) == TYPE_STRING:
			new_history[f] = new_history[f].replace("'", "")
			if "null" in new_history[f]:
				new_history[f] = null
	if action == "insert":
		new_history["NgayThem"] = str(Time.get_datetime_string_from_system()).replace("T", " ")
		new_history["HoatDong"] = "Thêm thông tin " + tableVietnameseName[tableName] + " mã " + str(new_history["Ma" + tableName]) + ": "
		for f in info.keys():
			new_history["HoatDong"] = new_history["HoatDong"] + f + ": "
			if f == "GioiTinh":
				if str(info[f]) == "0":
					new_history["HoatDong"] = new_history["HoatDong"] + "Nam" + ", "
				else:
					new_history["HoatDong"] = new_history["HoatDong"] + "Nữ" + ", "
			else:
				new_history["HoatDong"] = new_history["HoatDong"] + str(info[f]) + ", "
	else:
		db.query("select * from LichSu" + tableName + " where Ma" + tableName + " = " + str(new_history["Ma" + tableName]) + ";")
		new_history["NgayThem"] = db.query_result[0]["NgayThem"]
		if action == "edit":
			new_history["HoatDong"] = "Sửa thông tin " + tableVietnameseName[tableName] + " mã " + str(new_history["Ma" + tableName]) + ": "
			var last_result = db.query_result[db.query_result.size() - 1]
			for f in info.keys():
				if str(last_result[f]) != str(info[f]).replace("'", ""):
					new_history["HoatDong"] = new_history["HoatDong"] + f + ": "
					if f == "GioiTinh":
						if str(info[f]) == "0":
							new_history["HoatDong"] = new_history["HoatDong"] + "Nữ -> Nam" + ", "
						else:
							new_history["HoatDong"] = new_history["HoatDong"] + "Nam -> Nữ" + ", "
					else:
						new_history["HoatDong"] = new_history["HoatDong"] + str(last_result[f]) + " -> " + str(info[f]).replace("'", "") + ", "
		if action == "delete":
			new_history["HoatDong"] = "Xóa thông tin " + tableVietnameseName[tableName] + " mã " + str(new_history["Ma" + tableName]) + ": "
			for f in info.keys():
				new_history["HoatDong"] = new_history["HoatDong"] + f + ": "
				if f == "GioiTinh":
					if str(info[f]) == "0":
						new_history["HoatDong"] = new_history["HoatDong"] + "Nam" + ", "
					else:
						new_history["HoatDong"] = new_history["HoatDong"] + "Nữ" + ", "
				else:
					new_history["HoatDong"] = new_history["HoatDong"] + str(info[f]) + ", "
	new_history["SuaDoiLanCuoi"] = str(Time.get_datetime_string_from_system()).replace("T", " ")
	db.insert_row("LichSu" + tableName, new_history)
	print(new_history)















